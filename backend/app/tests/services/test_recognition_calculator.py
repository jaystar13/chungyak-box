from datetime import date

import pytest

from app.schemas import (
    CustomPaymentInput,
    PaymentAmountOption,
    RecognitionCalculatorRequest,
)
from app.services.recognized_date_calc import calculate_recognition_details


def test_calculate_recognition_details_simulation_maximum_option():
    # Given: A request for a simulation from Oct 2024 to Jan 2025
    # This crosses the recognition amount change date (Nov 2024)
    request = RecognitionCalculatorRequest(
        payment_day=10,
        start_date=date(2024, 10, 1),
        end_date=date(2025, 1, 31),
        payment_amount_option=PaymentAmountOption.maximum,
    )

    # When: The calculation is performed
    result = calculate_recognition_details(request)

    # Then: The results should be calculated correctly
    # Today is assumed to be after Jan 2025 for all rounds to be recognized
    # 4 rounds in total: Oct, Nov, Dec, Jan
    assert result.recognized_rounds == 4
    assert result.unrecognized_rounds == 0

    # Oct'24: 100,000 (before Nov 2024)
    # Nov'24: 250,000
    # Dec'24: 250,000
    # Jan'25: 250,000
    expected_total_amount = 100000 + 250000 + 250000 + 250000
    assert result.total_recognized_amount == expected_total_amount

    assert len(result.details) == 4

    # Check details for each round
    oct_round = result.details[0]
    assert oct_round.installment_no == 1
    assert oct_round.due_date == date(2024, 10, 10)
    assert oct_round.paid_date == date(2024, 10, 10)
    assert oct_round.is_recognized
    assert oct_round.paid_amount == 100000
    assert oct_round.recognized_amount_for_round == 100000
    assert oct_round.status == "정상"

    nov_round = result.details[1]
    assert nov_round.installment_no == 2
    assert nov_round.due_date == date(2024, 11, 10)
    assert nov_round.paid_date == date(2024, 11, 10)
    assert nov_round.is_recognized
    assert nov_round.paid_amount == 250000
    assert nov_round.recognized_amount_for_round == 250000
    assert nov_round.status == "정상"


def test_calculate_recognition_details_simulation_standard_option():
    # Given: A request for a simulation with a standard payment amount
    request = RecognitionCalculatorRequest(
        payment_day=15,
        start_date=date(2024, 1, 1),
        end_date=date(2024, 4, 30),
        payment_amount_option=PaymentAmountOption.standard,
        standard_payment_amount=50000,
    )

    # When: The calculation is performed
    result = calculate_recognition_details(request)

    # Then: The results should be calculated correctly
    # 4 rounds, all recognized
    assert result.recognized_rounds == 4
    assert result.unrecognized_rounds == 0
    # 4 * 50,000
    assert result.total_recognized_amount == 200000
    assert len(result.details) == 4

    # Check that each round has the correct paid and recognized amount
    for round_detail in result.details:
        assert round_detail.paid_amount == 50000
        assert round_detail.recognized_amount_for_round == 50000
        assert round_detail.is_recognized


def test_calculate_recognition_details_recalculation_with_delay():
    # Given: A request with a custom payment list including a delay
    # Round 2 is paid 10 days late.
    custom_payments = [
        CustomPaymentInput(installment_no=1, paid_date=date(2024, 1, 20)),
        CustomPaymentInput(
            installment_no=2, paid_date=date(2024, 2, 28)
        ),  # Due date is 20th, paid 8 days late
        CustomPaymentInput(installment_no=3, paid_date=date(2024, 3, 20)),
    ]
    request = RecognitionCalculatorRequest(
        payment_day=20,
        start_date=date(2024, 1, 1),
        end_date=date(2024, 3, 31),
        payment_amount_option=PaymentAmountOption.maximum,
        payments=custom_payments,
    )

    # When: The calculation is performed
    result = calculate_recognition_details(request)

    # Then: The results should reflect the delay
    assert result.recognized_rounds == 3
    assert len(result.details) == 3

    round_1 = result.details[0]
    assert round_1.status == "정상"
    assert round_1.due_date == date(2024, 1, 20)
    assert round_1.paid_date == date(2024, 1, 20)
    assert round_1.delay_days == 0
    assert round_1.total_delay_days == 0
    assert round_1.prepaid_days == 0
    assert round_1.total_prepaid_days == 0
    # recognized_date for the first round should be its due_date as there's no prior delay/prepayment
    assert round_1.recognized_date == date(2024, 1, 20)

    round_2 = result.details[1]
    assert round_2.status == "지연"
    assert round_2.due_date == date(2024, 2, 20)
    assert round_2.paid_date == date(2024, 2, 28)
    assert round_2.delay_days == 8
    assert round_2.total_delay_days == 8
    assert round_2.prepaid_days == 0
    assert round_2.total_prepaid_days == 0
    assert round_2.recognized_date == date(2024, 2, 24)

    round_3 = result.details[2]
    assert round_3.status == "정상"
    assert round_3.due_date == date(2024, 3, 20)
    assert round_3.paid_date == date(2024, 3, 20)
    assert round_3.delay_days == 0
    assert round_3.total_delay_days == 8
    assert round_3.prepaid_days == 0
    assert round_3.total_prepaid_days == 0
    assert round_3.recognized_date == date(2024, 3, 22)


def test_calculate_recognition_details_recalculation_with_prepayment():
    # Given: A request with a custom payment list including a prepayment
    # Round 2 is paid 10 days early.
    custom_payments = [
        CustomPaymentInput(installment_no=1, paid_date=date(2024, 1, 20)),
        CustomPaymentInput(
            installment_no=2, paid_date=date(2024, 2, 10)
        ),  # Due date is 20th, paid 10 days early
        CustomPaymentInput(installment_no=3, paid_date=date(2024, 3, 20)),
    ]
    request = RecognitionCalculatorRequest(
        payment_day=20,
        start_date=date(2024, 1, 1),
        end_date=date(2024, 3, 31),
        payment_amount_option=PaymentAmountOption.maximum,
        payments=custom_payments,
    )

    # When: The calculation is performed
    result = calculate_recognition_details(request)

    # Then: The results should reflect the prepayment
    assert result.recognized_rounds == 3
    assert len(result.details) == 3

    round_1 = result.details[0]
    assert round_1.status == "정상"
    assert round_1.prepaid_days == 0
    assert round_1.total_prepaid_days == 0
    assert round_1.recognized_date == date(2024, 1, 20)

    round_2 = result.details[1]
    assert round_2.status == "선납"
    assert round_2.prepaid_days == 10
    assert round_2.total_prepaid_days == 10
    assert round_2.recognized_date == date(2024, 2, 15)

    round_3 = result.details[2]
    assert round_3.status == "정상"
    assert round_3.prepaid_days == 0
    assert round_3.total_prepaid_days == 10
    assert round_3.recognized_date == date(2024, 3, 16)


def test_calculate_recognition_details_prepayment_over_limit_raises_error():
    # Given: A request with a large prepayment that exceeds the 2-year limit
    custom_payments = [
        CustomPaymentInput(installment_no=1, paid_date=date(2024, 1, 20)),
        # Pay 3 years early, which is > 721 days
        CustomPaymentInput(installment_no=2, paid_date=date(2021, 2, 20)),
    ]
    request = RecognitionCalculatorRequest(
        payment_day=20,
        start_date=date(2024, 1, 1),
        end_date=date(2024, 3, 31),
        payment_amount_option=PaymentAmountOption.maximum,
        payments=custom_payments,
    )

    # When/Then: The calculation should raise a ValueError
    with pytest.raises(ValueError) as excinfo:
        calculate_recognition_details(request)
    assert str(excinfo.value) == "선납일수는 최대 2년(721일)을 초과할 수 없습니다."


def test_calculate_recognition_details_with_custom_paid_amount():
    # Given: A request with custom paid amounts for specific installments
    custom_payments = [
        CustomPaymentInput(installment_no=1, paid_date=date(2024, 1, 10), paid_amount=70000), # Custom amount
        CustomPaymentInput(installment_no=2, paid_date=date(2024, 2, 10), paid_amount=120000), # Custom amount
        CustomPaymentInput(installment_no=3, paid_date=date(2024, 3, 10), paid_amount=None), # Fallback to standard/maximum
    ]
    request = RecognitionCalculatorRequest(
        payment_day=10,
        start_date=date(2024, 1, 1),
        end_date=date(2024, 3, 31),
        payment_amount_option=PaymentAmountOption.standard,
        standard_payment_amount=100000,
        payments=custom_payments,
    )

    # When: The calculation is performed
    result = calculate_recognition_details(request)

    # Then: The recognized amounts should reflect the custom paid amounts
    assert len(result.details) == 3

    # Round 1: Custom paid_amount 70000
    assert result.details[0].installment_no == 1
    assert result.details[0].paid_amount == 70000
    assert result.details[0].recognized_amount_for_round == 70000

    # Round 2: Custom paid_amount 120000 (capped at 100000 for standard option before Nov 2024)
    assert result.details[1].installment_no == 2
    assert result.details[1].paid_amount == 120000
    assert result.details[1].recognized_amount_for_round == 100000 # Capped by max_allowed_amount

    # Round 3: No custom paid_amount, falls back to standard_payment_amount
    assert result.details[2].installment_no == 3
    assert result.details[2].paid_amount == 100000
    assert result.details[2].recognized_amount_for_round == 100000

    assert result.total_recognized_amount == (70000 + 100000 + 100000)
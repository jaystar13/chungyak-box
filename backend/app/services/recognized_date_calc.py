from datetime import date, timedelta
from typing import Dict, List

from dateutil.relativedelta import relativedelta
from fastapi import HTTPException

from app.schemas import (
    CustomPaymentInput,
    PaymentAmountOption,
    PaymentInput,
    PaymentRecord,
    PaymentStatus,
    RecognitionCalculationResult,
    RecognitionCalculatorRequest,
    RecognitionRoundRecord,
)


def generate_normal_payments(
    open_date: date, due_day: int, end_date: date
) -> List[PaymentRecord]:
    """
    Generate normal payment records from open_date to end_date with given due_day
    """
    results = []
    i = 1
    current = date(open_date.year, open_date.month, open_date.day)

    while current <= end_date:
        results.append(
            PaymentRecord(
                installment_no=i,
                due_date=current,
                paid_date=current,
                delay_days=0,
                total_delay_days=0,
                prepaid_days=0,
                total_prepaid_days=0,
                recognized_date=current,
                is_recognized=True,
            )
        )

        next_month = current.month + 1
        next_year = current.year + (next_month - 1) // 12
        next_month = (next_month - 1) % 12 + 1
        current = date(next_year, next_month, open_date.day)
        i += 1

    return results


def recalc_payments(payments: List[PaymentInput]) -> List[PaymentRecord]:
    """
    Recalculate recognized dates based on payment records
    """
    results = []
    total_delay_days = 0
    total_prepaid_days = 0

    for payment in payments:
        # 선납 인정은 최대 24회차(=24개월)까지만 허용
        max_recognized_date = payment.due_date.replace(
            year=payment.due_date.year - (payment.due_date.month + 23) // 12,
            month=(payment.due_date.month + 23) % 12 + 1
        )
        if payment.paid_date < max_recognized_date:
            payment.paid_date = max_recognized_date

        delay_days = (payment.paid_date - payment.due_date).days
        prepaid_days = 0

        if delay_days > 0:
            total_delay_days += delay_days
        elif delay_days < 0:
            prepaid_days = abs(delay_days)
            total_prepaid_days += prepaid_days

        adjusment = (total_delay_days - total_prepaid_days) // payment.installment_no
        recognized_date = payment.due_date + timedelta(days=adjusment)

        results.append(
            PaymentRecord(
                installment_no=payment.installment_no,
                due_date=payment.due_date,
                paid_date=payment.paid_date,
                delay_days=delay_days if delay_days > 0 else 0,
                total_delay_days=total_delay_days,
                prepaid_days=prepaid_days,
                total_prepaid_days=total_prepaid_days,
                recognized_date=recognized_date,
                is_recognized=recognized_date <= date.today(),
            )
        )

    return results


RECOGNITION_AMOUNT_CHANGE_DATE = date(2024, 11, 1)


def calculate_recognition_details(
    request: RecognitionCalculatorRequest,
) -> RecognitionCalculationResult:
    all_rounds_data: List[Dict] = []
    installment_no_counter = 1
    current_month_start = request.start_date.replace(day=1)
    end_month_start = request.end_date.replace(day=1)

    # Step A: Generate Base Schedule & Step B: Apply Custom Payments (initial setup)
    custom_payments_map: Dict[int, CustomPaymentInput] = {}
    if request.payments:
        for cp in request.payments:
            custom_payments_map[cp.installment_no] = cp

    while current_month_start <= end_month_start:
        due_date = date(
            current_month_start.year, current_month_start.month, request.payment_day
        )
        # Ensure due_date is not past the end_date if end_date is mid-month
        if due_date > request.end_date:
            break

        custom_payment_for_round = custom_payments_map.get(installment_no_counter)
        paid_date_input = (
            custom_payment_for_round.paid_date if custom_payment_for_round else due_date
        )

        # Determine paid_amount for this round
        paid_amount = 0
        if custom_payment_for_round and custom_payment_for_round.paid_amount is not None:
            paid_amount = custom_payment_for_round.paid_amount
        elif request.payment_amount_option == PaymentAmountOption.standard:
            paid_amount = request.standard_payment_amount or 0
        elif request.payment_amount_option == PaymentAmountOption.maximum:
            if paid_date_input < RECOGNITION_AMOUNT_CHANGE_DATE:
                paid_amount = 100000
            else:
                paid_amount = 250000

        has_payment = paid_amount > 0
        paid_date = paid_date_input if has_payment else None

        all_rounds_data.append(
            {
                "installment_no": installment_no_counter,
                "due_date": due_date,
                "paid_date": paid_date,
                "paid_amount": paid_amount,
                "recognized_date": None,  # Will be calculated in next step
                "delay_days": 0,
                "prepaid_days": 0,
                "total_delay_days": 0,
                "total_prepaid_days": 0,
            }
        )
        installment_no_counter += 1
        current_month_start += relativedelta(months=1)

    # Step C: Calculate Recognized Dates (adapted from recalc_payments logic)
    total_delay_days = 0
    total_prepaid_days = 0

    for i, round_data in enumerate(all_rounds_data):
        payment = round_data  # Using round_data as payment for clarity

        # 선납 인정은 최대 24회차(=24개월)까지만 허용 (original logic from recalc_payments)
        # This logic needs to be adapted to the new structure.
        # For simplicity in this simulation, we'll assume paid_date is the actual paid date
        # and not adjust it based on max_recognized_date from the original recalc_payments
        # as the user's request is about *actual* paid dates.
        # If the user wants this specific "max 24 months prepayment" rule applied to their
        # custom paid_dates, it would need further clarification.
        # For now, we'll calculate delay/prepaid based on provided paid_date vs due_date.

        has_payment = payment["paid_amount"] > 0
        paid_date_for_calc = (
            payment["paid_date"] if has_payment and payment["paid_date"] else payment["due_date"]
        )

        delay_days_current = (
            (paid_date_for_calc - payment["due_date"]).days if has_payment else 0
        )
        prepaid_days_current = 0

        if delay_days_current > 0:
            total_delay_days += delay_days_current
        elif delay_days_current < 0:
            prepaid_days_current = abs(delay_days_current)
            if prepaid_days_current > 721:
                raise HTTPException(status_code=400, detail="회차별 선납일수는 최대 2년(721일)을 초과할 수 없습니다.")
            total_prepaid_days += prepaid_days_current

        # This adjustment logic is from the original recalc_payments
        # It seems to apply a cumulative adjustment based on total delay/prepaid days
        # divided by the current installment number.
        # This might need careful review if the user's intent for "recognized_date"
        # is different from the original system's definition.
        # For now, I'll keep it as it was in recalc_payments.
        adjusment = (total_delay_days - total_prepaid_days)
        if payment["installment_no"] > 0:  # Avoid division by zero
            adjusment //= payment["installment_no"]
        else:
            adjusment = 0  # Or handle as an error if installment_no can be 0

        recognized_date = (
            payment["due_date"] + timedelta(days=adjusment) if has_payment else None
        )

        round_data["recognized_date"] = recognized_date
        round_data["delay_days"] = delay_days_current if delay_days_current > 0 else 0
        round_data["prepaid_days"] = prepaid_days_current
        round_data["total_delay_days"] = total_delay_days
        round_data["total_prepaid_days"] = total_prepaid_days


    # Step D: Aggregate Final Results & Step E: Assemble and Return
    final_recognized_rounds = 0
    final_unrecognized_rounds = 0
    final_total_recognized_amount = 0
    detailed_records: List[RecognitionRoundRecord] = []

    for round_data in all_rounds_data:
        recognized_date_value = round_data["recognized_date"]
        is_recognized = (
            recognized_date_value is not None and recognized_date_value <= date.today()
        )

        recognized_amount_for_round = 0
        if is_recognized:
            # Recognized amount is the minimum of paid_amount and the max allowed for that date
            max_allowed_amount = 0
            paid_date_for_amount = round_data["paid_date"] or round_data["due_date"]
            if paid_date_for_amount < RECOGNITION_AMOUNT_CHANGE_DATE:
                max_allowed_amount = 100000
            else:
                max_allowed_amount = 250000
            recognized_amount_for_round = min(round_data["paid_amount"], max_allowed_amount)
            final_recognized_rounds += 1
            final_total_recognized_amount += recognized_amount_for_round
        else:
            final_unrecognized_rounds += 1

        status = PaymentStatus.normal
        if round_data["paid_amount"] == 0:
            status = PaymentStatus.missed
        elif round_data["delay_days"] > 0:
            status = PaymentStatus.delay
        elif round_data["prepaid_days"] > 0:
            status = PaymentStatus.prepaid

        detailed_records.append(
            RecognitionRoundRecord(
                installment_no=round_data["installment_no"],
                due_date=round_data["due_date"],
                paid_date=round_data["paid_date"],
                recognized_date=round_data["recognized_date"],
                delay_days=round_data["delay_days"],
                total_delay_days=round_data["total_delay_days"],
                prepaid_days=round_data["prepaid_days"],
                total_prepaid_days=round_data["total_prepaid_days"],
                status=status,
                is_recognized=is_recognized,
                paid_amount=round_data["paid_amount"],
                recognized_amount_for_round=recognized_amount_for_round,
            )
        )

    return RecognitionCalculationResult(
        payment_day=request.payment_day,
        start_date=request.start_date,
        end_date=request.end_date,
        recognized_rounds=final_recognized_rounds,
        unrecognized_rounds=final_unrecognized_rounds,
        total_recognized_amount=final_total_recognized_amount,
        details=detailed_records,
    )

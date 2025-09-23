from datetime import date, timedelta
from typing import List

from app.schemas import PaymentInput, PaymentRecord


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

from fastapi import APIRouter

from app.schemas import (
    NormalRequest,
    PaymentRespose,
    RecalcRequest,
    RecognitionCalculationResult,
    RecognitionCalculatorRequest,
)
from app.services.recognized_date_calc import (
    calculate_recognition_details,
    generate_normal_payments,
    recalc_payments,
)

router = APIRouter(tags=["payment-schedule"])


@router.post("/payments/normal", response_model=PaymentRespose)
def create_normal_schedule(request: NormalRequest) -> PaymentRespose:
    payments = generate_normal_payments(
        request.open_date, request.due_day, request.end_date
    )
    return _build_payment_response(payments, request.end_date)


@router.post("/payments/recalc", response_model=PaymentRespose)
def recalc_schedule(request: RecalcRequest) -> PaymentRespose:
    payments = recalc_payments(request.payments)
    return _build_payment_response(payments, request.end_date)


@router.post("/payments/calculate-recognition", response_model=RecognitionCalculationResult)
def calculate_recognition(request: RecognitionCalculatorRequest) -> RecognitionCalculationResult:
    return calculate_recognition_details(request)


def _build_payment_response(payments, current_date) -> PaymentRespose:
    if not payments:
        return PaymentRespose(total_installments=0, payments=[], total_delay_days=0, total_prepaid_days=0)
    
    last_payment = max(payments, key=lambda p: p.installment_no)
    total_installments_count = sum(1 for p in payments if p.recognized_date <= current_date)
    
    return PaymentRespose(
        total_installments=total_installments_count, 
        payments=payments, 
        total_delay_days=last_payment.total_delay_days, 
        total_prepaid_days=last_payment.total_prepaid_days)
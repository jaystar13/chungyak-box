from datetime import date
from enum import Enum
from typing import List, Optional

from pydantic import BaseModel


class PaymentRecord(BaseModel):
    installment_no: int
    due_date: date
    paid_date: date
    delay_days: int
    total_delay_days: int
    prepaid_days: int
    total_prepaid_days: int
    recognized_date: date
    is_recognized: bool = False


class PaymentInput(BaseModel):
    installment_no: int
    due_date: date
    paid_date: date


class NormalRequest(BaseModel):
    open_date: date
    due_day: int
    end_date: date


class RecalcRequest(BaseModel):
    open_date: date
    end_date: date
    payments: List[PaymentInput]


class PaymentRespose(BaseModel):
    total_installments: int
    total_delay_days: int = 0
    total_prepaid_days: int = 0
    payments: List[PaymentRecord]


class PaymentAmountOption(str, Enum):
    standard = "standard"
    maximum = "maximum"
    custom = "custom"


class CustomPaymentInput(BaseModel):
    installment_no: int
    paid_date: date
    paid_amount: Optional[int] = None


class RecognitionCalculatorRequest(BaseModel):
    payment_day: int
    start_date: date
    end_date: date
    payment_amount_option: PaymentAmountOption
    standard_payment_amount: Optional[int] = None
    payments: Optional[List[CustomPaymentInput]] = None


class PaymentStatus(str, Enum):
    normal = "정상"
    delay = "지연"
    prepaid = "선납"


class RecognitionRoundRecord(BaseModel):
    installment_no: int
    due_date: date
    paid_date: date
    recognized_date: date
    delay_days: int
    total_delay_days: int
    prepaid_days: int
    total_prepaid_days: int
    status: PaymentStatus
    is_recognized: bool
    paid_amount: int
    recognized_amount_for_round: int


class RecognitionCalculationResult(BaseModel):
    payment_day: int
    start_date: date
    end_date: date
    recognized_rounds: int
    unrecognized_rounds: int
    total_recognized_amount: int
    details: List[RecognitionRoundRecord]


class GoogleToken(BaseModel):
    token: str

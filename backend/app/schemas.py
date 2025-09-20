from datetime import date
from typing import List
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

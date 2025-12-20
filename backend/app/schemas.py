from datetime import date, datetime
from enum import Enum
from typing import List, Optional
import uuid

from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator

from app.models import TermType


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
    missed = "미납"


class RecognitionRoundRecord(BaseModel):
    installment_no: int
    due_date: date
    paid_date: Optional[date] = None
    recognized_date: Optional[date] = None
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


class NaverToken(BaseModel):
    token: str


class TempToken(BaseModel):
    token: str
    message: Optional[str] = "Terms agreement required"


class CompleteSocialSignup(BaseModel):
    token: str
    agreed_terms_ids: list[uuid.UUID]


# Schemas for Terms and UserAgreement
class TermsBase(BaseModel):
    version: str
    content: str
    term_type: TermType


class TermsCreate(TermsBase):
    pass


class TermsUpdate(TermsBase):
    pass


class Terms(TermsBase):
    id: uuid.UUID
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class LatestTermsResponse(BaseModel):
    terms_of_use: Optional[Terms] = None
    privacy_policy: Optional[Terms] = None


class UserAgreementBase(BaseModel):
    user_id: uuid.UUID
    terms_id: uuid.UUID


class UserAgreementCreate(UserAgreementBase):
    pass

# Shared properties
class UserBase(BaseModel):
    email: EmailStr
    is_active: bool = True
    is_superuser: bool = False
    full_name: Optional[str] = Field(default=None, max_length=255)

    model_config = ConfigDict(from_attributes=True)

# Properties to receive via API on creation
class UserCreate(UserBase):
    password: Optional[str] = None

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    password_confirm: str
    full_name: Optional[str] = Field(default=None, max_length=255)
    agreed_terms_ids: list[uuid.UUID]

    @model_validator(mode="after")
    def password_match(self) -> "UserRegister":
        if self.password != self.password_confirm:
            raise ValueError("passwords don't match")
        return self


# Properties to receive via API on update, all are optional
class UserUpdate(UserBase):
    email: Optional[EmailStr] = None  # type: ignore
    password: Optional[str] = None


class UserUpdateMe(BaseModel):
    full_name: Optional[str] = Field(default=None, max_length=255)
    email: Optional[EmailStr] = None


class UpdatePassword(BaseModel):
    current_password: str
    new_password: str

# Properties to return via API, id is always required
class UserPublic(UserBase):
    id: uuid.UUID
    social_accounts: List["SocialAccountPublic"] = []
    housing_subscription_detail: Optional["HousingSubscriptionDetailPublic"] = None


class UsersPublic(BaseModel):
    data: List[UserPublic]
    count: int

class SocialAccountPublic(BaseModel):
    provider: str

    model_config = ConfigDict(from_attributes=True)

class TermsPublic(BaseModel):
    id: uuid.UUID
    term_type: TermType
    version: str
    content: str
    created_at: datetime

class UserAgreementPublic(BaseModel):
    terms: TermsPublic
    agreed_at: datetime


# Schemas for HousingSubscriptionDetail
class HousingSubscriptionDetailBase(BaseModel):
    calculation_result: RecognitionCalculationResult


class HousingSubscriptionDetailCreate(HousingSubscriptionDetailBase):
    pass


class HousingSubscriptionDetailPublic(HousingSubscriptionDetailBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


# Shared properties
class ItemBase(BaseModel):
    title: str
    description: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

# Properties to receive on item creation
class ItemCreate(ItemBase):
    pass


# Properties to receive on item update
class ItemUpdate(ItemBase):
    title: Optional[str] = None  # type: ignore


# Properties to return via API, id is always required
class ItemPublic(ItemBase):
    id: uuid.UUID
    owner_id: uuid.UUID


class ItemsPublic(BaseModel):
    data: List[ItemPublic]
    count: int


# Generic message
class Message(BaseModel):
    message: str


# JSON payload containing access token
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenPair(Token):
    refresh_token: str


class TokenPairWithUser(TokenPair):
    user: UserPublic


class TokenWithUser(Token):
    user: UserPublic


# Contents of JWT token
class TokenPayload(BaseModel):
    sub: Optional[str] = None


class NewPassword(BaseModel):
    token: str
    new_password: str

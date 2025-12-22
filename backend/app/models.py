from typing import Optional
import uuid
from datetime import datetime
from enum import Enum

from pydantic import EmailStr
from sqlalchemy import JSON, Column, DateTime
from sqlmodel import Field, Relationship, SQLModel

class UserBase(SQLModel):
    email: EmailStr = Field(unique=True, index=True, max_length=255)
    is_active: bool = True
    is_superuser: bool = False
    full_name: str | None = Field(default=None, max_length=255)

# Database model, database table inferred from class name
class User(UserBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    hashed_password: str | None = Field(default=None)
    items: list["Item"] = Relationship(back_populates="owner", cascade_delete=True)
    social_accounts: list["SocialAccount"] = Relationship(
        back_populates="user", cascade_delete=True
    )
    agreements: list["UserAgreement"] = Relationship(back_populates="user", cascade_delete=True)
    housing_subscription_detail: Optional["HousingSubscriptionDetail"]= Relationship(
        back_populates="user", cascade_delete=True
    )


class SocialAccount(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    provider: str = Field(max_length=50, index=True)
    provider_user_id: str = Field(max_length=255, index=True)
    user_id: uuid.UUID = Field(foreign_key="user.id")
    user: User | None = Relationship(back_populates="social_accounts")


class TermType(str, Enum):
    TERMS_OF_USE = "terms_of_use"
    PRIVACY_POLICY = "privacy_policy"


class UserAgreement(SQLModel, table=True):
    user_id: uuid.UUID = Field(foreign_key="user.id", primary_key=True)
    terms_id: uuid.UUID = Field(foreign_key="terms.id", primary_key=True)
    agreed_at: datetime = Field(
        default_factory=datetime.now, nullable=False
    )
    user: "User" = Relationship(back_populates="agreements")
    terms: "Terms" = Relationship(back_populates="agreements")


class Terms(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    term_type: TermType = Field(index=True)
    version: str = Field(max_length=50)
    content: str
    created_at: datetime = Field(
        default_factory=datetime.now, nullable=False, index=True
    )
    agreements: list["UserAgreement"] = Relationship(back_populates="terms")


class ItemBase(SQLModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = Field(default=None, max_length=255)

# Database model, database table inferred from class name
class Item(ItemBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    owner_id: uuid.UUID = Field(foreign_key="user.id", nullable=False)
    owner: User | None = Relationship(back_populates="items")


class HousingSubscriptionDetail(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    calculation_result: dict = Field(default={}, sa_column=Column(JSON))
    created_at: datetime = Field(default_factory=datetime.now, nullable=False)
    updated_at: datetime = Field(
        default_factory=datetime.now, sa_column_kwargs={"onupdate": datetime.now}
    )
    user_id: uuid.UUID = Field(foreign_key="user.id", unique=True, nullable=False)
    user: "User" = Relationship(back_populates="housing_subscription_detail")


class UserWithdrawal(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(index=True)
    hashed_email: str = Field(index=True)
    withdrawn_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), nullable=False)
    )
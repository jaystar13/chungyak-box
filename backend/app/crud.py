import uuid
from typing import Any
from datetime import datetime, timezone

from sqlmodel import Session, select

from app.core.security import get_password_hash, verify_password
from app.models import (
    HousingSubscriptionDetail,
    Item,
    SocialAccount,
    Terms,
    TermType,
    User,
    UserAgreement,
    UserWithdrawal,
)
from app.schemas import (
    HousingSubscriptionDetailCreate,
    ItemCreate,
    TermsCreate,
    UserAgreementCreate,
    UserCreate,
    UserUpdate,
)


def create_user(*, session: Session, user_create: UserCreate) -> User:
    hashed_password = (
        get_password_hash(user_create.password) if user_create.password else None
    )
    db_obj = User.model_validate(
        user_create, update={"hashed_password": hashed_password}
    )
    session.add(db_obj)
    session.commit()
    session.refresh(db_obj)
    return db_obj


def update_user(*, session: Session, db_user: User, user_in: UserUpdate) -> Any:
    user_data = user_in.model_dump(exclude_unset=True)
    extra_data = {}
    if "password" in user_data:
        password = user_data["password"]
        hashed_password = get_password_hash(password)
        extra_data["hashed_password"] = hashed_password
    db_user.sqlmodel_update(user_data, update=extra_data)
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user


def get_user_by_email(*, session: Session, email: str) -> User | None:
    statement = select(User).where(User.email == email)
    session_user = session.exec(statement).first()
    return session_user


def get_social_account(
    *, session: Session, provider: str, provider_user_id: str
) -> SocialAccount | None:
    statement = select(SocialAccount).where(
        SocialAccount.provider == provider,
        SocialAccount.provider_user_id == provider_user_id,
    )
    session_social_account = session.exec(statement).first()
    return session_social_account


def create_social_account(
    *, session: Session, user_id: uuid.UUID, provider: str, provider_user_id: str
) -> SocialAccount:
    db_obj = SocialAccount(
        user_id=user_id, provider=provider, provider_user_id=provider_user_id
    )
    session.add(db_obj)
    session.commit()
    session.refresh(db_obj)
    return db_obj


def authenticate(*, session: Session, email: str, password: str) -> User | None:
    db_user = get_user_by_email(session=session, email=email)
    if not db_user:
        return None
    if not db_user.hashed_password:
        return None
    if not verify_password(password, db_user.hashed_password):
        return None
    return db_user


def create_item(*, session: Session, item_in: ItemCreate, owner_id: uuid.UUID) -> Item:
    db_item = Item.model_validate(item_in, update={"owner_id": owner_id})
    session.add(db_item)
    session.commit()
    session.refresh(db_item)
    return db_item


def create_terms(*, session: Session, terms_in: TermsCreate) -> Terms:
    db_obj = Terms.model_validate(terms_in)
    session.add(db_obj)
    session.commit()
    session.refresh(db_obj)
    return db_obj


def get_latest_terms(session: Session) -> dict[TermType, Terms | None]:
    latest_terms: dict[TermType, Terms | None] = {}
    for term_type in TermType:
        statement = (
            select(Terms)
            .where(Terms.term_type == term_type)
            .order_by(Terms.created_at.desc())
        )
        latest_term = session.exec(statement).first()
        latest_terms[term_type] = latest_term
    return latest_terms


def create_user_agreement(*, session: Session, agreement_in: UserAgreementCreate) -> UserAgreement:
    db_obj = UserAgreement.model_validate(agreement_in)
    session.add(db_obj)
    session.commit()
    session.refresh(db_obj)
    return db_obj


def get_agreements_by_user(*, session: Session, user_id: uuid.UUID) -> list[UserAgreement]:
    statement = select(UserAgreement).where(UserAgreement.user_id == user_id)
    agreements = session.exec(statement).all()
    return agreements


def get_housing_subscription_detail_by_user_id(
    *, session: Session, user_id: uuid.UUID
) -> HousingSubscriptionDetail | None:
    statement = select(HousingSubscriptionDetail).where(
        HousingSubscriptionDetail.user_id == user_id
    )
    return session.exec(statement).first()


def create_housing_subscription_detail(
    *,
    session: Session,
    detail_in: HousingSubscriptionDetailCreate,
    user_id: uuid.UUID
) -> HousingSubscriptionDetail:
    # calculation_result is a Pydantic model, so we dump it to a dict
    # Using mode="json" to ensure date objects are serialized to strings
    db_obj = HousingSubscriptionDetail(
        user_id=user_id,
        calculation_result=detail_in.calculation_result.model_dump(mode="json"),
    )
    session.add(db_obj)
    session.commit()
    session.refresh(db_obj)
    return db_obj


def remove_housing_subscription_detail_by_user_id(
    *, session: Session, user_id: uuid.UUID
) -> HousingSubscriptionDetail | None:
    db_obj = get_housing_subscription_detail_by_user_id(
        session=session, user_id=user_id
    )
    if db_obj:
        session.delete(db_obj)
        session.commit()
    return db_obj


def withdraw_user(*, session: Session, user: User) -> None:
    # Record user withdrawal
    user_withdrawal_record = UserWithdrawal(
        user_id=user.id,
        hashed_email=get_password_hash(user.email),
        withdrawn_at=datetime.now(timezone.utc),
    )
    session.add(user_withdrawal_record)

    # Delete the user (related data will be cascade deleted)
    session.delete(user)
    session.commit()

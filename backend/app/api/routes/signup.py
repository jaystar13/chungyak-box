from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session

from app import crud
from app.api.deps import get_db
from app.core.security import create_access_token
from app.models import TermType
from app.schemas import (
    TokenWithUser,
    UserAgreementCreate,
    UserCreate,
    UserPublic,
    UserRegister,
)


router = APIRouter(tags=["signup"])


@router.post("/", response_model=TokenWithUser, status_code=status.HTTP_201_CREATED)
def create_user(
    *,
    session: Annotated[Session, Depends(get_db)],
    user_in: UserRegister,
):
    """
    Create new user.
    """
    user = crud.get_user_by_email(session=session, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="이미 등록된 이메일입니다.",
        )

    # Validate agreed terms
    latest_terms = crud.get_latest_terms(session)
    required_term_ids = {
        term.id
        for term_type, term in latest_terms.items()
        if term is not None
        and (
            term_type == TermType.TERMS_OF_USE
            or term_type == TermType.PRIVACY_POLICY
        )
    }

    if not required_term_ids.issubset(set(user_in.agreed_terms_ids)):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="필수 약관에 동의해주세요.",
        )

    user_create = UserCreate.model_validate(
        user_in.model_dump(exclude={"password_confirm", "agreed_terms_ids"})
    )
    user = crud.create_user(session=session, user_create=user_create)

    # Save user agreements
    for term_id in user_in.agreed_terms_ids:
        crud.create_user_agreement(
            session=session,
            agreement_in=UserAgreementCreate(user_id=user.id, terms_id=term_id),
        )

    access_token = create_access_token(subject=user.id)
    return TokenWithUser(
        access_token=access_token, user=UserPublic.model_validate(user)
    )

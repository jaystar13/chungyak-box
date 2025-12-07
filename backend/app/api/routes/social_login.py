from typing import Annotated
import uuid # Added import

import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import JSONResponse
from google.auth.transport import requests
from google.oauth2 import id_token
from sqlmodel import Session

from app import crud
from app.api.deps import get_db
from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    create_temp_token,
    decode_temp_token,
)
from app.models import TermType
from app.schemas import (
    CompleteSocialSignup,
    GoogleToken,
    NaverToken,
    TempToken,
    TokenPairWithUser,
    UserAgreementCreate,
    UserCreate,
)

router = APIRouter(tags=["login"])


@router.post("/google", response_model=TokenPairWithUser)
async def google_login(
    google_token: GoogleToken,
    db: Annotated[Session, Depends(get_db)],
):
    if not settings.GOOGLE_CLIENT_ID:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Google client ID not configured.",
        )

    try:
        id_info = id_token.verify_oauth2_token(
            google_token.token, requests.Request(), settings.GOOGLE_CLIENT_ID
        )
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate Google credentials.",
        )

    email = id_info.get("email")
    provider_user_id = id_info.get("sub")

    if not email or not provider_user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Google token is missing email or sub.",
        )

    # 1. Check if social account already exists
    social_account = crud.get_social_account(
        session=db, provider="google", provider_user_id=provider_user_id
    )
    if social_account:
        user = social_account.user
    else:
        # 2. If not, check if a user with this email already exists
        user = crud.get_user_by_email(session=db, email=email)
        if user:
            # 2a. If user exists, link the social account (account integration)
            crud.create_social_account(
                session=db,
                user_id=user.id,
                provider="google",
                provider_user_id=provider_user_id,
            )
        else:
            # 2b. If no user exists, send a temporary token for signup
            temp_token_data = {
                "provider": "google",
                "provider_user_id": provider_user_id,
                "email": email,
                "full_name": id_info.get("name"),
            }
            temp_token = create_temp_token(data=temp_token_data)
            return JSONResponse(
                status_code=status.HTTP_202_ACCEPTED,
                content=TempToken(token=temp_token).model_dump(),
            )

    if not user:
        # This should not happen in normal flow
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not create or retrieve user.",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user"
        )

    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)

    return TokenPairWithUser(
        access_token=access_token, refresh_token=refresh_token, user=user
    )


@router.post("/naver", response_model=TokenPairWithUser)
async def naver_login(
    naver_token: NaverToken,
    db: Annotated[Session, Depends(get_db)],
):
    if not settings.NAVER_CLIENT_ID or not settings.NAVER_CLIENT_SECRET:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Naver client ID or secret not configured.",
        )

    headers = {
        "Authorization": f"Bearer {naver_token.token}",
    }
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(
                "https://openapi.naver.com/v1/nid/me", headers=headers
            )
            response.raise_for_status()
            id_info = response.json()
        except httpx.HTTPStatusError as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Could not validate Naver credentials: {e.response.text}",
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"An error occurred during Naver login: {str(e)}",
            )

    naver_response = id_info.get("response")
    if not naver_response:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid response from Naver.",
        )

    email = naver_response.get("email")
    provider_user_id = naver_response.get("id")

    if not email or not provider_user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Naver token is missing email or id.",
        )

    # 1. Check if social account already exists
    social_account = crud.get_social_account(
        session=db, provider="naver", provider_user_id=provider_user_id
    )
    if social_account:
        user = social_account.user
    else:
        # 2. If not, check if a user with this email already exists
        user = crud.get_user_by_email(session=db, email=email)
        if user:
            # 2a. If user exists, link the social account
            crud.create_social_account(
                session=db,
                user_id=user.id,
                provider="naver",
                provider_user_id=provider_user_id,
            )
        else:
            # 2b. If no user exists, send a temporary token for signup
            temp_token_data = {
                "provider": "naver",
                "provider_user_id": provider_user_id,
                "email": email,
                "full_name": naver_response.get("name"),
            }
            temp_token = create_temp_token(data=temp_token_data)
            return JSONResponse(
                status_code=status.HTTP_202_ACCEPTED,
                content=TempToken(token=temp_token).model_dump(),
            )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not create or retrieve user.",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user"
        )

    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)

    return TokenPairWithUser(
        access_token=access_token, refresh_token=refresh_token, user=user
    )


@router.post("/social-signup/complete", response_model=TokenPairWithUser)
async def complete_social_signup(
    signup_data: CompleteSocialSignup,
    db: Annotated[Session, Depends(get_db)],
):
    try:
        payload = decode_temp_token(signup_data.token)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=f"Invalid token: {e}"
        )

    provider = payload.get("provider")
    provider_user_id = payload.get("provider_user_id")
    email = payload.get("email")
    full_name = payload.get("full_name")

    if not all([provider, provider_user_id, email]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incomplete data in token.",
        )

    # Validate agreed terms
    latest_terms = crud.get_latest_terms(db)
    required_term_ids = {
        term.id
        for term_type, term in latest_terms.items()
        if term is not None and (
            term_type == TermType.TERMS_OF_USE or
            term_type == TermType.PRIVACY_POLICY
        )
    }

    if not required_term_ids.issubset(set(signup_data.agreed_terms_ids)):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Missing agreement for required terms.",
        )

    # Re-check if user or social account was created in the meantime
    social_account = crud.get_social_account(
        session=db, provider=provider, provider_user_id=provider_user_id
    )
    if social_account:
        user = social_account.user
    else:
        user = crud.get_user_by_email(session=db, email=email)
        if user:
            # Link account if user with same email created via another method
            crud.create_social_account(
                session=db,
                user_id=user.id,
                provider=provider,
                provider_user_id=provider_user_id,
            )
        else:
            # Create new user and social account
            user_create = UserCreate(email=email, full_name=full_name)
            user = crud.create_user(session=db, user_create=user_create)
            crud.create_social_account(
                session=db,
                user_id=user.id,
                provider=provider,
                provider_user_id=provider_user_id,
            )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not create or retrieve user after signup completion.",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user"
        )

    # Save user agreements
    for term_id in signup_data.agreed_terms_ids:
        crud.create_user_agreement(
            session=db, agreement_in=UserAgreementCreate(user_id=user.id, terms_id=term_id)
        )

    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)
    return TokenPairWithUser(
        access_token=access_token, refresh_token=refresh_token, user=user
    )
from datetime import timedelta
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from google.auth.transport import requests
from google.oauth2 import id_token
from sqlmodel import Session

from app import crud
from app.api.deps import get_db
from app.core.config import settings
from app.core.security import create_access_token
from app.models import Token, TokenWithUser, UserCreate
from app.schemas import GoogleToken

router = APIRouter(tags=["login"])


@router.post("/google", response_model=TokenWithUser)
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
    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Google token did not contain an email address.",
        )

    user = crud.get_user_by_email(session=db, email=email)
    if not user:
        user_create = UserCreate(
            email=email,
            full_name=id_info.get("name"),
            social_provider="google",
            social_id=id_info.get("sub"),
            # No password for social login users
            password=None,
        )
        user = crud.create_user(session=db, user_create=user_create)

    # Check if the user is active, although Google login implies active
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user"
        )

    access_token = create_access_token(subject=user.id)

    return TokenWithUser(access_token=access_token, user=user)
from typing import Any

from fastapi import APIRouter
from pydantic import BaseModel

from app.api.deps import CurrentUser, SessionDep
from app.core.security import get_password_hash
from app.models import User
from app.schemas import UserPublic

router = APIRouter(tags=["private"], prefix="/private")


@router.get("/me", response_model=UserPublic)
def read_current_user(current_user: CurrentUser) -> Any:
    """
    Get current user.
    """
    return current_user


class PrivateUserCreate(BaseModel):
    email: str
    password: str
    full_name: str


@router.post("/users", response_model=UserPublic)
def create_user(user_in: PrivateUserCreate, session: SessionDep) -> Any:
    """
    Create a new user.
    """

    user = User(
        email=user_in.email,
        full_name=user_in.full_name,
        hashed_password=get_password_hash(user_in.password),
    )

    session.add(user)
    session.commit()

    return user

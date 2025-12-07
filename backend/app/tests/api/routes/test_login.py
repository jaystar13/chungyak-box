from fastapi.testclient import TestClient
from sqlmodel import Session

from app import crud
from app.core.config import settings
from app.schemas import UserCreate
from app.tests.utils.utils import random_email, random_lower_string


def test_login_access_token(client: TestClient, db: Session) -> None:
    email = random_email()
    password = random_lower_string()
    user_in = UserCreate(email=email, password=password)
    crud.create_user(session=db, user_create=user_in)

    login_data = {"username": email, "password": password}
    r = client.post(f"{settings.API_V1_STR}/login/access-token", data=login_data)
    response = r.json()
    assert r.status_code == 200
    assert "access_token" in response
    assert response["access_token"]


def test_login_access_token_with_wrong_password(
    client: TestClient, db: Session
) -> None:
    email = random_email()
    password = random_lower_string()
    wrong_password = random_lower_string()
    user_in = UserCreate(email=email, password=password)
    crud.create_user(session=db, user_create=user_in)

    login_data = {"username": email, "password": wrong_password}
    r = client.post(f"{settings.API_V1_STR}/login/access-token", data=login_data)
    response = r.json()
    assert r.status_code == 400
    assert response["detail"] == "Incorrect email or password"
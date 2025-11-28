from unittest.mock import patch

from fastapi import status
from fastapi.testclient import TestClient
from sqlmodel import Session, select

from app.core.config import settings
from app.models import User


def test_google_login_new_user(client: TestClient, db: Session) -> None:
    # Mock the Google ID token verification
    with patch("google.oauth2.id_token.verify_oauth2_token") as mock_verify:
        mock_verify.return_value = {
            "email": "new.user@example.com",
            "name": "New User",
            "sub": "google_new_user_id",
        }
        
        # Ensure GOOGLE_CLIENT_ID is set for the test
        original_client_id = settings.GOOGLE_CLIENT_ID
        settings.GOOGLE_CLIENT_ID = "test-client-id"

        response = client.post(
            f"{settings.API_V1_STR}/login/google",
            json={"token": "mock_google_id_token"},
        )
        settings.GOOGLE_CLIENT_ID = original_client_id # Revert client ID

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

    user = db.exec(select(User).where(User.email == "new.user@example.com")
    ).first()
    assert user is not None
    assert user.full_name == "New User"
    assert user.social_provider == "google"
    assert user.social_id == "google_new_user_id"
    assert user.hashed_password is None


def test_google_login_existing_user(client: TestClient, db: Session) -> None:
    # Create an existing user with social login details
    user_email = "existing.user@example.com"
    existing_user = User(
        email=user_email,
        full_name="Existing User",
        social_provider="google",
        social_id="google_existing_user_id",
        hashed_password=None,
    )
    db.add(existing_user)
    db.commit()
    db.refresh(existing_user)

    with patch("google.oauth2.id_token.verify_oauth2_token") as mock_verify:
        mock_verify.return_value = {
            "email": user_email,
            "name": "Existing User",
            "sub": "google_existing_user_id",
        }
        
        # Ensure GOOGLE_CLIENT_ID is set for the test
        original_client_id = settings.GOOGLE_CLIENT_ID
        settings.GOOGLE_CLIENT_ID = "test-client-id"

        response = client.post(
            f"{settings.API_V1_STR}/login/google",
            json={"token": "mock_google_id_token"},
        )
        settings.GOOGLE_CLIENT_ID = original_client_id # Revert client ID

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

    user_after_login = db.exec(select(User).where(User.email == user_email)
    ).first()
    assert user_after_login is not None
    assert user_after_login.id == existing_user.id
    assert user_after_login.full_name == "Existing User"
    assert user_after_login.social_provider == "google"
    assert user_after_login.social_id == "google_existing_user_id"


def test_google_login_invalid_token(client: TestClient) -> None:
    with patch("google.oauth2.id_token.verify_oauth2_token") as mock_verify:
        mock_verify.side_effect = ValueError("Invalid token")
        
        # Ensure GOOGLE_CLIENT_ID is set for the test
        original_client_id = settings.GOOGLE_CLIENT_ID
        settings.GOOGLE_CLIENT_ID = "test-client-id"

        response = client.post(
            f"{settings.API_V1_STR}/login/google",
            json={"token": "invalid_google_id_token"},
        )
        settings.GOOGLE_CLIENT_ID = original_client_id # Revert client ID

    assert response.status_code == status.HTTP_401_UNAUTHORIZED
    assert response.json()["detail"] == "Could not validate Google credentials."


def test_google_login_client_id_not_configured(client: TestClient) -> None:
    # Temporarily unset GOOGLE_CLIENT_ID for this test
    original_client_id = settings.GOOGLE_CLIENT_ID
    settings.GOOGLE_CLIENT_ID = None

    response = client.post(
        f"{settings.API_V1_STR}/login/google",
        json={"token": "mock_google_id_token"},
    )
    # Revert GOOGLE_CLIENT_ID
    settings.GOOGLE_CLIENT_ID = original_client_id

    assert response.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
    assert response.json()["detail"] == "Google client ID not configured."
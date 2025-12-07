from unittest.mock import patch

from fastapi import status
from fastapi.testclient import TestClient
from sqlmodel import Session, select

from app.core.config import settings
from app.models import SocialAccount, User


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
        settings.GOOGLE_CLIENT_ID = original_client_id  # Revert client ID

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

    user = db.exec(select(User).where(User.email == "new.user@example.com")).first()
    assert user is not None
    assert user.full_name == "New User"
    assert user.hashed_password is None

    social_account = db.exec(
        select(SocialAccount).where(SocialAccount.user_id == user.id)
    ).first()
    assert social_account is not None
    assert social_account.provider == "google"
    assert social_account.provider_user_id == "google_new_user_id"


def test_google_login_returning_user(client: TestClient, db: Session) -> None:
    # Create an existing user and a social account link
    user_email = "returning.user@example.com"
    provider_user_id = "google_returning_user_id"
    existing_user = User(
        email=user_email, full_name="Returning User", hashed_password=None
    )
    db.add(existing_user)
    db.commit()
    db.refresh(existing_user)
    social_account = SocialAccount(
        user_id=existing_user.id, provider="google", provider_user_id=provider_user_id
    )
    db.add(social_account)
    db.commit()

    with patch("google.oauth2.id_token.verify_oauth2_token") as mock_verify:
        mock_verify.return_value = {
            "email": user_email,
            "name": "Returning User",
            "sub": provider_user_id,
        }

        original_client_id = settings.GOOGLE_CLIENT_ID
        settings.GOOGLE_CLIENT_ID = "test-client-id"
        response = client.post(
            f"{settings.API_V1_STR}/login/google",
            json={"token": "mock_google_id_token"},
        )
        settings.GOOGLE_CLIENT_ID = original_client_id

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "access_token" in data
    assert data["user"]["id"] == str(existing_user.id)

    # Verify no new user or social account was created
    # We expect 2 users: the superuser created by init_db and the one for this test
    users_count = len(db.exec(select(User)).all())
    assert users_count == 2
    social_accounts_count = len(db.exec(select(SocialAccount)).all())
    assert social_accounts_count == 1


def test_google_login_account_integration(
    client: TestClient, db: Session
) -> None:
    # 1. Create a regular user with email and password
    user_email = "integration.user@example.com"
    normal_user = User(
        email=user_email,
        full_name="Integration User",
        hashed_password="some_password_hash",
    )
    db.add(normal_user)
    db.commit()
    db.refresh(normal_user)

    # 2. Simulate Google login with the same email
    provider_user_id = "google_integration_user_id"
    with patch("google.oauth2.id_token.verify_oauth2_token") as mock_verify:
        mock_verify.return_value = {
            "email": user_email,
            "name": "Integration User Name Updated?", # Name might differ
            "sub": provider_user_id,
        }

        original_client_id = settings.GOOGLE_CLIENT_ID
        settings.GOOGLE_CLIENT_ID = "test-client-id"
        response = client.post(
            f"{settings.API_V1_STR}/login/google",
            json={"token": "mock_google_id_token"},
        )
        settings.GOOGLE_CLIENT_ID = original_client_id

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "access_token" in data
    assert data["user"]["id"] == str(normal_user.id)

    # 3. Verify a new SocialAccount was created and linked
    social_account = db.exec(
        select(SocialAccount).where(SocialAccount.provider_user_id == provider_user_id)
    ).first()
    assert social_account is not None
    assert social_account.user_id == normal_user.id
    assert social_account.provider == "google"

    # 4. Verify no new user was created
    # We expect 2 users: the superuser created by init_db and the one for this test
    users_count = len(db.exec(select(User)).all())
    assert users_count == 2


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
        settings.GOOGLE_CLIENT_ID = original_client_id  # Revert client ID

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
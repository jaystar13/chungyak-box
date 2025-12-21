from fastapi.testclient import TestClient
from sqlmodel import Session, select

from app.core.config import settings
from app.models import User, UserWithdrawal
from app.crud import get_user_by_email
from app.core.security import get_password_hash
from app.tests.utils.user import create_random_user


def test_delete_my_account(client: TestClient, superuser_token_headers: dict, db: Session) -> None:
    # Create a random user to delete
    user_to_delete_password = "test_password"
    user_to_delete = create_random_user(db, password=user_to_delete_password)
    
    # Authenticate as the user to delete
    login_data = {
        "username": user_to_delete.email,
        "password": user_to_delete_password,
    }
    r = client.post(
        f"{settings.API_V1_STR}/login/access-token", data=login_data
    )
    tokens = r.json()
    user_token_headers = {"Authorization": f"Bearer {tokens['access_token']}"}

    # Delete the user's account
    r = client.delete(
        f"{settings.API_V1_STR}/users/me", headers=user_token_headers
    )
    assert r.status_code == 200
    response_data = r.json()
    assert response_data["message"] == "Account deleted successfully"

    # Verify user is deleted from the User table
    deleted_user = get_user_by_email(session=db, email=user_to_delete.email)
    assert deleted_user is None

    # Verify a record exists in UserWithdrawal table
    withdrawal_record = db.exec(
        select(UserWithdrawal).where(UserWithdrawal.user_id == user_to_delete.id)
    ).first()
    assert withdrawal_record is not None
    assert withdrawal_record.hashed_email == get_password_hash(user_to_delete.email)

    # Try to log in with the deleted user's credentials (should fail)
    r = client.post(
        f"{settings.API_V1_STR}/login/access-token", data=login_data
    )
    assert r.status_code == 400 # Or 404 depending on error handling

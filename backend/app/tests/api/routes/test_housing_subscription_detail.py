from fastapi.testclient import TestClient
from sqlmodel import Session, select

from app import crud
from app.core.config import settings
from app.models import HousingSubscriptionDetail
from app.schemas import RecognitionCalculationResult
from app.tests.utils.user import authentication_token_from_email
from app.tests.utils.utils import random_email


def test_save_housing_subscription_detail_unauthorized(client: TestClient) -> None:
    """
    Test saving a housing subscription detail without authentication.
    """
    payload = {
        "payment_day": 10,
        "start_date": "2022-01-01",
        "end_date": "2023-12-31",
        "recognized_rounds": 12,
        "unrecognized_rounds": 0,
        "total_recognized_amount": 1200000,
        "details": [],
    }
    response = client.post(
        f"{settings.API_V1_STR}/me/housing-subscription-detail", json=payload
    )
    assert response.status_code == 401


def test_save_new_housing_subscription_detail(client: TestClient, db: Session) -> None:
    """
    Test saving a new housing subscription detail for the first time.
    """
    email = random_email()
    headers = authentication_token_from_email(client=client, email=email, db=db)
    user = crud.get_user_by_email(session=db, email=email)
    assert user

    payload = {
        "payment_day": 10,
        "start_date": "2022-01-01",
        "end_date": "2023-12-31",
        "recognized_rounds": 24,
        "unrecognized_rounds": 0,
        "total_recognized_amount": 2400000,
        "details": [],
    }
    response = client.post(
        f"{settings.API_V1_STR}/me/housing-subscription-detail",
        headers=headers,
        json=payload,
    )
    assert response.status_code == 200
    data = response.json()
    assert data["calculation_result"]["recognized_rounds"] == 24
    assert data["calculation_result"]["total_recognized_amount"] == 2400000
    assert data["user_id"] == str(user.id)

    db_detail = crud.get_housing_subscription_detail_by_user_id(
        session=db, user_id=user.id
    )
    assert db_detail
    assert db_detail.calculation_result["recognized_rounds"] == 24
    assert db_detail.calculation_result["total_recognized_amount"] == 2400000


def test_update_housing_subscription_detail(client: TestClient, db: Session) -> None:
    """
    Test updating an existing housing subscription detail by saving a new one.
    """
    email = random_email()
    headers = authentication_token_from_email(client=client, email=email, db=db)
    user = crud.get_user_by_email(session=db, email=email)
    assert user

    # 1. Save the first detail
    payload1 = {
        "payment_day": 10,
        "start_date": "2022-01-01",
        "end_date": "2023-12-31",
        "recognized_rounds": 24,
        "unrecognized_rounds": 0,
        "total_recognized_amount": 2400000,
        "details": [],
    }
    response1 = client.post(
        f"{settings.API_V1_STR}/me/housing-subscription-detail",
        headers=headers,
        json=payload1,
    )
    assert response1.status_code == 200
    db_detail1 = crud.get_housing_subscription_detail_by_user_id(
        session=db, user_id=user.id
    )
    assert db_detail1

    # 2. Save the second detail, which should replace the first one
    payload2 = {
        "payment_day": 15,
        "start_date": "2021-01-01",
        "end_date": "2024-12-31",
        "recognized_rounds": 36,
        "unrecognized_rounds": 2,
        "total_recognized_amount": 3600000,
        "details": [],
    }
    response2 = client.post(
        f"{settings.API_V1_STR}/me/housing-subscription-detail",
        headers=headers,
        json=payload2,
    )
    assert response2.status_code == 200
    data2 = response2.json()
    assert data2["calculation_result"]["recognized_rounds"] == 36

    db.refresh(user)
    db_detail2 = crud.get_housing_subscription_detail_by_user_id(
        session=db, user_id=user.id
    )
    assert db_detail2
    assert db_detail1.id != db_detail2.id  # Should be a new record
    assert db_detail2.calculation_result["recognized_rounds"] == 36

    # 3. Ensure there is only one detail record for the user
    statement = select(HousingSubscriptionDetail).where(
        HousingSubscriptionDetail.user_id == user.id
    )
    results = db.exec(statement).all()
    assert len(results) == 1


def test_get_housing_subscription_detail_unauthorized(client: TestClient) -> None:
    """
    Test getting a housing subscription detail without authentication.
    """
    response = client.get(f"{settings.API_V1_STR}/me/housing-subscription-detail")
    assert response.status_code == 401


def test_get_housing_subscription_detail_not_exist(
    client: TestClient, db: Session
) -> None:
    """
    Test getting a housing subscription detail for a user who hasn't saved one.
    """
    email = random_email()
    headers = authentication_token_from_email(client=client, email=email, db=db)
    response = client.get(
        f"{settings.API_V1_STR}/me/housing-subscription-detail", headers=headers
    )
    assert response.status_code == 200
    assert response.json() is None


def test_get_housing_subscription_detail_exist(client: TestClient, db: Session) -> None:
    """
    Test getting an existing housing subscription detail.
    """
    email = random_email()
    headers = authentication_token_from_email(client=client, email=email, db=db)
    user = crud.get_user_by_email(session=db, email=email)
    assert user

    # First, save a detail to the DB
    payload = {
        "payment_day": 10,
        "start_date": "2022-01-01",
        "end_date": "2023-12-31",
        "recognized_rounds": 24,
        "unrecognized_rounds": 0,
        "total_recognized_amount": 2400000,
        "details": [],
    }
    post_response = client.post(
        f"{settings.API_V1_STR}/me/housing-subscription-detail",
        headers=headers,
        json=payload,
    )
    assert post_response.status_code == 200

    # Then, get the detail
    get_response = client.get(
        f"{settings.API_V1_STR}/me/housing-subscription-detail", headers=headers
    )
    assert get_response.status_code == 200
    data = get_response.json()
    assert data is not None
    assert data["user_id"] == str(user.id)
    assert data["calculation_result"]["recognized_rounds"] == 24
    assert data["calculation_result"]["total_recognized_amount"] == 2400000

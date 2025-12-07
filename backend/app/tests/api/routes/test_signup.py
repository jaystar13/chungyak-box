from fastapi.testclient import TestClient
from sqlmodel import Session

from app import crud
from app.core.config import settings
from app.models import TermType
from app.schemas import TermsCreate, UserCreate


def test_create_user_new_email(client: TestClient, db: Session) -> None:
    # Create required terms
    terms_of_use = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.TERMS_OF_USE, version="1.0", content="Test terms of use"
        ),
    )
    privacy_policy = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.PRIVACY_POLICY,
            version="1.0",
            content="Test privacy policy",
        ),
    )
    agreed_terms_ids = [str(terms_of_use.id), str(privacy_policy.id)]

    email = "test@example.com"
    password = "password123"
    password_confirm = "password123"
    full_name = "Test User"
    data = {
        "email": email,
        "password": password,
        "password_confirm": password_confirm,
        "full_name": full_name,
        "agreed_terms_ids": agreed_terms_ids,
    }
    r = client.post(
        f"{settings.API_V1_STR}/signup",
        json=data,
    )
    created_user = r.json()
    assert r.status_code == 200
    assert "access_token" in created_user
    assert created_user["user"]["email"] == email
    assert created_user["user"]["full_name"] == full_name
    user_in_db = crud.get_user_by_email(session=db, email=email)
    assert user_in_db is not None
    assert user_in_db.email == email
    assert user_in_db.full_name == full_name

    # Verify that agreements were saved
    agreements = crud.get_agreements_by_user(session=db, user_id=user_in_db.id)
    assert len(agreements) == len(agreed_terms_ids)
    agreed_term_ids_in_db = {str(a.terms_id) for a in agreements}
    assert agreed_term_ids_in_db == set(agreed_terms_ids)


def test_create_user_missing_terms(client: TestClient, db: Session) -> None:
    # Create required terms but user doesn't agree to all
    crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.TERMS_OF_USE, version="1.0", content="Test terms of use"
        ),
    )
    privacy_policy = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.PRIVACY_POLICY,
            version="1.0",
            content="Test privacy policy",
        ),
    )
    # User only agrees to privacy policy, not terms of use
    agreed_terms_ids = [str(privacy_policy.id)]

    email = "test_missing_terms@example.com"
    password = "password123"
    password_confirm = "password123"
    full_name = "Test User"
    data = {
        "email": email,
        "password": password,
        "password_confirm": password_confirm,
        "full_name": full_name,
        "agreed_terms_ids": agreed_terms_ids,
    }
    r = client.post(
        f"{settings.API_V1_STR}/signup",
        json=data,
    )
    assert r.status_code == 400
    assert "Missing agreement for required terms" in r.json()["detail"]


def test_create_user_existing_email(client: TestClient, db: Session) -> None:
    # Create required terms
    terms_of_use = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.TERMS_OF_USE, version="1.0", content="Test terms of use"
        ),
    )
    privacy_policy = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.PRIVACY_POLICY,
            version="1.0",
            content="Test privacy policy",
        ),
    )
    agreed_terms_ids = [str(terms_of_use.id), str(privacy_policy.id)]

    email = "test@example.com"
    password = "password123"
    password_confirm = "password123"
    full_name = "Test User"

    # Create user once
    user_create = UserCreate(email=email, password=password, full_name=full_name)
    crud.create_user(session=db, user_create=user_create)

    data = {
        "email": email,
        "password": password,
        "password_confirm": password_confirm,
        "full_name": full_name,
        "agreed_terms_ids": agreed_terms_ids,
    }
    r = client.post(
        f"{settings.API_V1_STR}/signup",
        json=data,
    )
    assert r.status_code == 400
    assert "already exists" in r.json()["detail"]


def test_create_user_password_mismatch(client: TestClient, db: Session) -> None:
    # Create required terms
    terms_of_use = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.TERMS_OF_USE, version="1.0", content="Test terms of use"
        ),
    )
    privacy_policy = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.PRIVACY_POLICY,
            version="1.0",
            content="Test privacy policy",
        ),
    )
    agreed_terms_ids = [str(terms_of_use.id), str(privacy_policy.id)]

    email = "test2@example.com"
    password = "password123"
    password_confirm = "password456"  # Mismatch
    full_name = "Test User Two"
    data = {
        "email": email,
        "password": password,
        "password_confirm": password_confirm,
        "full_name": full_name,
        "agreed_terms_ids": agreed_terms_ids,
    }
    r = client.post(
        f"{settings.API_V1_STR}/signup",
        json=data,
    )
    assert r.status_code == 422  # Unprocessable Entity for validation errors
    assert "passwords don't match" in r.json()["detail"][0]["msg"]


def test_create_user_short_password(client: TestClient, db: Session) -> None:
    # Create required terms
    terms_of_use = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.TERMS_OF_USE, version="1.0", content="Test terms of use"
        ),
    )
    privacy_policy = crud.create_terms(
        session=db,
        terms_in=TermsCreate(
            term_type=TermType.PRIVACY_POLICY,
            version="1.0",
            content="Test privacy policy",
        ),
    )
    agreed_terms_ids = [str(terms_of_use.id), str(privacy_policy.id)]

    email = "test3@example.com"
    password = "short"  # Too short
    password_confirm = "short"
    full_name = "Test User Three"
    data = {
        "email": email,
        "password": password,
        "password_confirm": password_confirm,
        "full_name": full_name,
        "agreed_terms_ids": agreed_terms_ids,
    }
    r = client.post(
        f"{settings.API_V1_STR}/signup",
        json=data,
    )
    assert r.status_code == 422  # Unprocessable Entity for validation errors
    assert "String should have at least 8 characters" in r.json()["detail"][0]["msg"]
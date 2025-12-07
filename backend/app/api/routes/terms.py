from typing import Annotated

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app import crud
from app.api.deps import get_db
from app.models import TermType
from app.schemas import LatestTermsResponse

router = APIRouter(tags=["terms"])


@router.get("/latest", response_model=LatestTermsResponse)
def get_latest_terms(session: Annotated[Session, Depends(get_db)]):
    """
    Retrieve the latest version of each type of term.
    """
    latest_terms = crud.get_latest_terms(session)
    return LatestTermsResponse(
        terms_of_use=latest_terms.get(TermType.TERMS_OF_USE),
        privacy_policy=latest_terms.get(TermType.PRIVACY_POLICY),
    )

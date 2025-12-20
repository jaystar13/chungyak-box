from typing import Any

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app import crud
from app.api.deps import CurrentUser, SessionDep
from app.schemas import (
    HousingSubscriptionDetailCreate,
    HousingSubscriptionDetailPublic,
    RecognitionCalculationResult,
)

router = APIRouter(tags=["Housing Subscription Detail"])


@router.get(
    "/me/housing-subscription-detail",
    response_model=HousingSubscriptionDetailPublic | None,
)
def get_housing_subscription_detail(
    *, session: SessionDep, current_user: CurrentUser
) -> Any:
    """
    Get the housing subscription detail for the current user.
    """
    detail = crud.get_housing_subscription_detail_by_user_id(
        session=session, user_id=current_user.id
    )
    return detail


@router.post(
    "/me/housing-subscription-detail",
    response_model=HousingSubscriptionDetailPublic,
)
def save_or_update_housing_subscription_detail(
    *,
    session: SessionDep,
    current_user: CurrentUser,
    detail_in: RecognitionCalculationResult
) -> Any:
    """
    Save or update the housing subscription detail for the current user.
    If detail already exists, it will be replaced.
    """
    # First, remove any existing detail for the current user
    crud.remove_housing_subscription_detail_by_user_id(
        session=session, user_id=current_user.id
    )

    # Then, create the new detail
    detail_create = HousingSubscriptionDetailCreate(calculation_result=detail_in)
    new_detail = crud.create_housing_subscription_detail(
        session=session, detail_in=detail_create, user_id=current_user.id
    )
    return new_detail

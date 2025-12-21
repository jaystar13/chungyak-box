from fastapi import APIRouter

from app.api.routes import (
    housing_subscription_detail,
    login,
    payment_schedule,
    private,
    social_login,
    terms,
    signup,
    user,
)
from app.core.config import settings

api_router = APIRouter()
api_router.include_router(login.router)
api_router.include_router(social_login.router, prefix="/login")
api_router.include_router(signup.router, prefix="/signup")
api_router.include_router(payment_schedule.router)
api_router.include_router(terms.router, prefix="/terms")
api_router.include_router(housing_subscription_detail.router)
api_router.include_router(user.router, prefix="/users")


if settings.ENVIRONMENT == "local":
    api_router.include_router(private.router)

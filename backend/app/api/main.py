from fastapi import APIRouter

from app.core.config import settings
from app.api.routes import private, login, payment_schedule

api_router = APIRouter()
api_router.include_router(login.router)
api_router.include_router(payment_schedule.router)


if settings.ENVIRONMENT == "local":
    api_router.include_router(private.router)

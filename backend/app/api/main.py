from fastapi import APIRouter

from app.api.routes import login, payment_schedule, private
from app.core.config import settings

api_router = APIRouter()
api_router.include_router(login.router)
api_router.include_router(payment_schedule.router)


if settings.ENVIRONMENT == "local":
    api_router.include_router(private.router)

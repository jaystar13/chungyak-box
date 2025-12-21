from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session

from app import crud
from app.api import deps
from app.models import User

router = APIRouter(tags=["users"])


@router.delete("/me", status_code=status.HTTP_200_OK)
def delete_my_account(
    session: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user),
):
    """
    Delete the currently authenticated user's account.
    All personal information will be deleted.
    """
    if not current_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )
    
    crud.withdraw_user(session=session, user=current_user)
    return {"message": "Account deleted successfully"}

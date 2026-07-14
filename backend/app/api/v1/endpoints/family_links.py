from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.schemas.family_link import FamilyLinkResponse, FamilyLinkCreateRequest
from app.services.family_link_service import family_link_service
from app.api.deps import get_current_active_user
from app.models.user import User

router = APIRouter()

@router.get("", response_model=List[FamilyLinkResponse])
async def list_family_links(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
) -> List[FamilyLinkResponse]:
    """List all family links associated with the current user."""
    links = await family_link_service.list_links(db, current_user)
    return [FamilyLinkResponse.model_validate(l) for l in links]

@router.post("", response_model=FamilyLinkResponse, status_code=status.HTTP_201_CREATED)
async def initiate_family_link(
    create_data: FamilyLinkCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
) -> FamilyLinkResponse:
    """Initiate a new family link (Nurse only)."""
    link = await family_link_service.initiate_link(db, current_user, create_data)
    return FamilyLinkResponse.model_validate(link)

@router.patch("/{uuid}/accept", response_model=FamilyLinkResponse)
async def accept_family_link(
    uuid: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
) -> FamilyLinkResponse:
    """Accept a pending family link initiated for the current user (Partner only)."""
    link = await family_link_service.accept_link(db, current_user, uuid)
    return FamilyLinkResponse.model_validate(link)

@router.delete("/{uuid}", response_model=FamilyLinkResponse)
async def revoke_family_link(
    uuid: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
) -> FamilyLinkResponse:
    """Revoke an active or pending family link."""
    link = await family_link_service.revoke_link(db, current_user, uuid)
    return FamilyLinkResponse.model_validate(link)

import uuid
from datetime import datetime, timezone
from typing import Sequence
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.models.family_link import FamilyLink, FamilyLinkStatus
from app.models.user import User, UserRole
from app.schemas.family_link import FamilyLinkCreateRequest

class FamilyLinkService:
    """Service layer encapsulating family link initiation, acceptance, and revocation lifecycle."""

    async def list_links(self, db: AsyncSession, user: User) -> Sequence[FamilyLink]:
        stmt = (
            select(FamilyLink)
            .options(selectinload(FamilyLink.primary_nurse), selectinload(FamilyLink.partner_user))
            .where((FamilyLink.primary_nurse_id == user.id) | (FamilyLink.partner_user_id == user.id))
            .order_by(FamilyLink.created_at.desc())
        )
        result = await db.scalars(stmt)
        return result.all()

    async def initiate_link(self, db: AsyncSession, nurse: User, create_data: FamilyLinkCreateRequest) -> FamilyLink:
        if nurse.role != UserRole.NURSE:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only users with NURSE role can initiate family links"
            )

        if create_data.partner_phone:
            partner_stmt = select(User).where(User.phone == create_data.partner_phone)
        else:
            partner_stmt = select(User).where(User.uuid == create_data.partner_user_uuid)

        partner = await db.scalar(partner_stmt)
        if not partner:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Partner user not found"
            )

        if partner.id == nurse.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot link with yourself"
            )

        if partner.role != UserRole.PARTNER:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Target user must have the PARTNER role"
            )

        check_stmt = select(FamilyLink).where(
            (FamilyLink.primary_nurse_id == nurse.id)
            & (FamilyLink.partner_user_id == partner.id)
            & (FamilyLink.status != FamilyLinkStatus.REVOKED)
        )
        existing = await db.scalar(check_stmt)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="An active or pending family link already exists between these accounts"
            )

        new_uuid = str(uuid.uuid4())
        link = FamilyLink(
            uuid=new_uuid,
            primary_nurse_id=nurse.id,
            partner_user_id=partner.id,
            status=FamilyLinkStatus.PENDING
        )
        db.add(link)
        await db.commit()

        reload_stmt = (
            select(FamilyLink)
            .options(selectinload(FamilyLink.primary_nurse), selectinload(FamilyLink.partner_user))
            .where(FamilyLink.id == link.id)
        )
        return await db.scalar(reload_stmt)

    async def accept_link(self, db: AsyncSession, partner: User, link_uuid: str) -> FamilyLink:
        stmt = (
            select(FamilyLink)
            .options(selectinload(FamilyLink.primary_nurse), selectinload(FamilyLink.partner_user))
            .where(FamilyLink.uuid == link_uuid)
        )
        link = await db.scalar(stmt)
        if not link:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Family link not found"
            )

        if link.partner_user_id != partner.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You are not authorized to accept this family link"
            )

        if link.status != FamilyLinkStatus.PENDING:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot accept link in status {link.status}"
            )

        link.status = FamilyLinkStatus.ACTIVE
        link.linked_at = datetime.now(timezone.utc)
        await db.commit()
        await db.refresh(link)
        return link

    async def revoke_link(self, db: AsyncSession, user: User, link_uuid: str) -> FamilyLink:
        stmt = (
            select(FamilyLink)
            .options(selectinload(FamilyLink.primary_nurse), selectinload(FamilyLink.partner_user))
            .where(FamilyLink.uuid == link_uuid)
        )
        link = await db.scalar(stmt)
        if not link:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Family link not found"
            )

        if link.primary_nurse_id != user.id and link.partner_user_id != user.id and user.role != UserRole.ADMIN:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You are not authorized to revoke this family link"
            )

        if link.status == FamilyLinkStatus.REVOKED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Link is already revoked"
            )

        link.status = FamilyLinkStatus.REVOKED
        await db.commit()
        await db.refresh(link)
        return link

family_link_service = FamilyLinkService()

from datetime import datetime
from typing import TYPE_CHECKING, Optional
import enum
from sqlalchemy import ForeignKey, Enum, DateTime, func, UniqueConstraint, Index, BigInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

if TYPE_CHECKING:
    from app.models.user import User

class FamilyLinkStatus(str, enum.Enum):
    PENDING = "PENDING"
    ACTIVE = "ACTIVE"
    REVOKED = "REVOKED"

class FamilyLink(Base):
    """FamilyLink model connecting a primary nurse with family members/partners (Table 4)."""
    __tablename__ = "family_links"
    __table_args__ = (
        UniqueConstraint("primary_nurse_id", "partner_user_id", name="uq_family_links_pair"),
        Index("idx_family_partner", "partner_user_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True)
    primary_nurse_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    partner_user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    status: Mapped[FamilyLinkStatus] = mapped_column(Enum(FamilyLinkStatus), default=FamilyLinkStatus.PENDING, nullable=False)
    linked_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    primary_nurse: Mapped["User"] = relationship("User", foreign_keys=[primary_nurse_id], back_populates="family_links_primary")
    partner_user: Mapped["User"] = relationship("User", foreign_keys=[partner_user_id], back_populates="family_links_partner")

from datetime import datetime
from typing import Optional, TYPE_CHECKING
import enum
from sqlalchemy import String, ForeignKey, Enum, DateTime, func, Index, BigInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

if TYPE_CHECKING:
    from app.models.department import Department
    from app.models.user import User
    from app.models.schedule import Schedule

class SwapStatus(str, enum.Enum):
    PENDING = "PENDING"
    ACCEPTED = "ACCEPTED"
    CONFIRMED = "CONFIRMED"
    COMPLETED = "COMPLETED"
    REJECTED = "REJECTED"
    CANCELLED = "CANCELLED"
    EXPIRED = "EXPIRED"

class ShiftSwap(Base):
    """ShiftSwap model representing peer-to-peer shift swap proposals (Table 5)."""
    __tablename__ = "shift_swaps"
    __table_args__ = (
        Index("idx_swap_department", "department_id"),
        Index("idx_swap_requester", "requester_id"),
        Index("idx_swap_recipient", "recipient_id"),
        Index("idx_swap_status", "status"),
        Index("idx_swap_dept_status", "department_id", "status"),
    )

    id: Mapped[int] = mapped_column(BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False, index=True)
    department_id: Mapped[int] = mapped_column(ForeignKey("departments.id"), nullable=False)
    requester_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    recipient_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    requester_schedule_id: Mapped[int] = mapped_column(ForeignKey("schedules.id"), nullable=False)
    recipient_schedule_id: Mapped[int] = mapped_column(ForeignKey("schedules.id"), nullable=False)
    status: Mapped[SwapStatus] = mapped_column(Enum(SwapStatus), default=SwapStatus.PENDING, nullable=False)
    requester_confirmed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    recipient_confirmed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    message: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    completed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    department: Mapped["Department"] = relationship("Department")
    requester: Mapped["User"] = relationship("User", foreign_keys=[requester_id], back_populates="shift_swaps_requested")
    recipient: Mapped["User"] = relationship("User", foreign_keys=[recipient_id], back_populates="shift_swaps_received")
    requester_schedule: Mapped["Schedule"] = relationship("Schedule", foreign_keys=[requester_schedule_id])
    recipient_schedule: Mapped["Schedule"] = relationship("Schedule", foreign_keys=[recipient_schedule_id])

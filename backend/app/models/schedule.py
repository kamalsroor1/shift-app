from datetime import datetime, date as date_type
from typing import Optional, TYPE_CHECKING
import enum
from sqlalchemy import String, ForeignKey, Enum, Date, DateTime, func, UniqueConstraint, Index, BigInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

if TYPE_CHECKING:
    from app.models.user import User

class ShiftType(str, enum.Enum):
    LONG = "LONG"
    NIGHT = "NIGHT"
    OFF = "OFF"

class ScheduleSource(str, enum.Enum):
    MANUAL = "MANUAL"
    SWAP = "SWAP"
    SALE = "SALE"
    ADMIN = "ADMIN"

class Schedule(Base):
    """Schedule model representing a nurse's shift assignment on a date (Table 3)."""
    __tablename__ = "schedules"
    __table_args__ = (
        UniqueConstraint("user_id", "date", name="uq_schedules_user_date"),
        Index("idx_schedules_date", "date"),
        Index("idx_schedules_user_month", "user_id", "date"),
    )

    id: Mapped[int] = mapped_column(BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    date: Mapped[date_type] = mapped_column(Date, nullable=False)
    shift_type: Mapped[ShiftType] = mapped_column(Enum(ShiftType), nullable=False)
    source: Mapped[ScheduleSource] = mapped_column(Enum(ScheduleSource), default=ScheduleSource.MANUAL, nullable=False)
    note: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    user: Mapped["User"] = relationship("User", back_populates="schedules")

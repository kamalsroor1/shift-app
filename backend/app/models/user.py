from datetime import datetime
from typing import Optional, List, TYPE_CHECKING
import enum
from sqlalchemy import String, ForeignKey, Enum, DateTime, func, Index, BigInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

if TYPE_CHECKING:
    from app.models.department import Department
    from app.models.schedule import Schedule
    from app.models.family_link import FamilyLink
    from app.models.shift_swap import ShiftSwap
    from app.models.shift_sale import ShiftSale
    from app.models.financial_ledger import FinancialLedger

class UserRole(str, enum.Enum):
    NURSE = "nurse"
    PARTNER = "partner"
    ADMIN = "admin"

class User(Base):
    """User model representing a nurse, partner, or department admin (Table 2)."""
    __tablename__ = "users"
    __table_args__ = (
        Index("idx_users_dept", "department_id"),
        Index("idx_users_role", "role"),
    )

    id: Mapped[int] = mapped_column(BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False, index=True)
    department_id: Mapped[int] = mapped_column(ForeignKey("departments.id", ondelete="RESTRICT"), nullable=False)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    employee_id: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    phone: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(191), unique=True, nullable=True)
    password: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), default=UserRole.NURSE, nullable=False)
    fcm_token: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    department: Mapped["Department"] = relationship("Department", back_populates="users")
    schedules: Mapped[List["Schedule"]] = relationship("Schedule", back_populates="user", cascade="all, delete-orphan")
    family_links_primary: Mapped[List["FamilyLink"]] = relationship("FamilyLink", foreign_keys="[FamilyLink.primary_nurse_id]", back_populates="primary_nurse")
    family_links_partner: Mapped[List["FamilyLink"]] = relationship("FamilyLink", foreign_keys="[FamilyLink.partner_user_id]", back_populates="partner_user")
    shift_swaps_requested: Mapped[List["ShiftSwap"]] = relationship("ShiftSwap", foreign_keys="[ShiftSwap.requester_id]", back_populates="requester")
    shift_swaps_received: Mapped[List["ShiftSwap"]] = relationship("ShiftSwap", foreign_keys="[ShiftSwap.recipient_id]", back_populates="recipient")
    shift_sales_sold: Mapped[List["ShiftSale"]] = relationship("ShiftSale", foreign_keys="[ShiftSale.seller_id]", back_populates="seller")
    shift_sales_bought: Mapped[List["ShiftSale"]] = relationship("ShiftSale", foreign_keys="[ShiftSale.buyer_id]", back_populates="buyer")
    ledger_debits: Mapped[List["FinancialLedger"]] = relationship("FinancialLedger", foreign_keys="[FinancialLedger.from_user_id]", back_populates="from_user")
    ledger_credits: Mapped[List["FinancialLedger"]] = relationship("FinancialLedger", foreign_keys="[FinancialLedger.to_user_id]", back_populates="to_user")

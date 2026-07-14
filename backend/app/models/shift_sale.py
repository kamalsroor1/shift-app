from datetime import datetime
from typing import Optional, List, TYPE_CHECKING
import enum
from decimal import Decimal
from sqlalchemy import String, ForeignKey, Enum, DateTime, func, Index, Numeric, BigInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

if TYPE_CHECKING:
    from app.models.department import Department
    from app.models.user import User
    from app.models.schedule import Schedule
    from app.models.financial_ledger import FinancialLedger

class SaleStatus(str, enum.Enum):
    LISTED = "LISTED"
    PURCHASED = "PURCHASED"
    CONFIRMED = "CONFIRMED"
    SETTLED = "SETTLED"
    CANCELLED = "CANCELLED"
    EXPIRED = "EXPIRED"

class ShiftSale(Base):
    """ShiftSale model representing marketplace shift listings (Table 6)."""
    __tablename__ = "shift_sales"
    __table_args__ = (
        Index("idx_sale_department", "department_id"),
        Index("idx_sale_seller", "seller_id"),
        Index("idx_sale_buyer", "buyer_id"),
        Index("idx_sale_status", "status"),
        Index("idx_sale_dept_status", "department_id", "status"),
    )

    id: Mapped[int] = mapped_column(BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False, index=True)
    department_id: Mapped[int] = mapped_column(ForeignKey("departments.id"), nullable=False)
    seller_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    buyer_id: Mapped[Optional[int]] = mapped_column(ForeignKey("users.id"), nullable=True)
    schedule_id: Mapped[int] = mapped_column(ForeignKey("schedules.id"), unique=True, nullable=False)
    asking_amount: Mapped[Decimal] = mapped_column(Numeric(10, 2), default=Decimal("0.00"), nullable=False)
    status: Mapped[SaleStatus] = mapped_column(Enum(SaleStatus), default=SaleStatus.LISTED, nullable=False)
    seller_note: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    purchased_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    settled_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    department: Mapped["Department"] = relationship("Department")
    seller: Mapped["User"] = relationship("User", foreign_keys=[seller_id], back_populates="shift_sales_sold")
    buyer: Mapped[Optional["User"]] = relationship("User", foreign_keys=[buyer_id], back_populates="shift_sales_bought")
    schedule: Mapped["Schedule"] = relationship("Schedule")
    ledger_entries: Mapped[List["FinancialLedger"]] = relationship("FinancialLedger", back_populates="shift_sale")

from datetime import datetime
from typing import Optional, TYPE_CHECKING
import enum
from decimal import Decimal
from sqlalchemy import String, ForeignKey, Enum, DateTime, func, Index, Numeric, event, BigInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship, object_session
from app.models.base import Base
from app.exceptions import ImmutableRecordException

if TYPE_CHECKING:
    from app.models.shift_sale import ShiftSale
    from app.models.user import User

class EntryType(str, enum.Enum):
    DEBIT = "DEBIT"
    CREDIT = "CREDIT"

class LedgerStatus(str, enum.Enum):
    UNSETTLED = "UNSETTLED"
    SETTLED = "SETTLED"

class FinancialLedger(Base):
    """FinancialLedger model representing double-entry financial records (Table 7)."""
    __tablename__ = "financial_ledger"
    __table_args__ = (
        Index("idx_ledger_transaction", "transaction_ref"),
        Index("idx_ledger_from_user", "from_user_id"),
        Index("idx_ledger_to_user", "to_user_id"),
        Index("idx_ledger_status", "status"),
        Index("idx_ledger_sale", "shift_sale_id"),
        Index("idx_ledger_from_status", "from_user_id", "status"),
        Index("idx_ledger_to_status", "to_user_id", "status"),
    )

    id: Mapped[int] = mapped_column(BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False, index=True)
    transaction_ref: Mapped[str] = mapped_column(String(36), nullable=False)
    shift_sale_id: Mapped[int] = mapped_column(ForeignKey("shift_sales.id"), nullable=False)
    from_user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    to_user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    entry_type: Mapped[EntryType] = mapped_column(Enum(EntryType), nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    currency: Mapped[str] = mapped_column(String(3), default="IQD", nullable=False)
    status: Mapped[LedgerStatus] = mapped_column(Enum(LedgerStatus), default=LedgerStatus.UNSETTLED, nullable=False)
    settled_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    settled_by: Mapped[Optional[int]] = mapped_column(ForeignKey("users.id"), nullable=True)
    note: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    shift_sale: Mapped["ShiftSale"] = relationship("ShiftSale", back_populates="ledger_entries")
    from_user: Mapped["User"] = relationship("User", foreign_keys=[from_user_id], back_populates="ledger_debits")
    to_user: Mapped["User"] = relationship("User", foreign_keys=[to_user_id], back_populates="ledger_credits")
    settled_by_user: Mapped[Optional["User"]] = relationship("User", foreign_keys=[settled_by])

# Immutability Guard event listener enforcing RULE 3.4
@event.listens_for(FinancialLedger, "before_update")
def receive_before_update(mapper, connection, target):
    from sqlalchemy.orm.attributes import get_history
    session = object_session(target)
    if session and session.is_modified(target, include_collections=False):
        history = get_history(target, 'status')
        # If status was SETTLED (either unchanged or being modified from SETTLED), raise exception
        if (history.deleted and history.deleted[0] == LedgerStatus.SETTLED) or (history.unchanged and history.unchanged[0] == LedgerStatus.SETTLED):
            raise ImmutableRecordException("Settled ledger records cannot be modified.")

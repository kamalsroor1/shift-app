import pytest
from decimal import Decimal
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.base import Base
from app.models.department import Department
from app.models.user import User, UserRole
from app.models.schedule import Schedule, ShiftType, ScheduleSource
from app.models.family_link import FamilyLink, FamilyLinkStatus
from app.models.shift_swap import ShiftSwap, SwapStatus
from app.models.shift_sale import ShiftSale, SaleStatus
from app.models.financial_ledger import FinancialLedger, EntryType, LedgerStatus
from app.exceptions import ImmutableRecordException

def test_models_have_correct_tablenames():
    """Verify all 7 models map to exact database table names per database_schema.md."""
    assert Department.__tablename__ == "departments"
    assert User.__tablename__ == "users"
    assert Schedule.__tablename__ == "schedules"
    assert FamilyLink.__tablename__ == "family_links"
    assert ShiftSwap.__tablename__ == "shift_swaps"
    assert ShiftSale.__tablename__ == "shift_sales"
    assert FinancialLedger.__tablename__ == "financial_ledger"

def test_schedule_has_unique_user_date_constraint():
    """Verify uq_schedules_user_date constraint exists on Schedule model (RULE 3.5)."""
    constraint_names = [
        c.name for c in Schedule.__table__.constraints
        if hasattr(c, "name") and c.name == "uq_schedules_user_date"
    ]
    assert "uq_schedules_user_date" in constraint_names

def test_departments_unique_constraints():
    """Verify unique constraints on uuid and code for departments."""
    col_dict = Department.__table__.columns
    assert col_dict["uuid"].unique is True
    assert col_dict["code"].unique is True

def test_ledger_immutability_guard_event_listener():
    """Verify that modifying a SETTLED financial ledger record triggers ImmutableRecordException (RULE 3.4)."""
    # Create in-memory SQLite engine to test SQLAlchemy event hook behavior
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()

    # Create dummy department and users to satisfy foreign keys
    dept = Department(uuid="dept-1", name="ICU", code="ICU-1")
    session.add(dept)
    session.flush()

    seller = User(uuid="user-1", department_id=dept.id, full_name="Seller Nurse", employee_id="EMP1", phone="111", password="pass")
    buyer = User(uuid="user-2", department_id=dept.id, full_name="Buyer Nurse", employee_id="EMP2", phone="222", password="pass")
    session.add_all([seller, buyer])
    session.flush()

    import datetime as dt_module
    sched = Schedule(uuid="sched-1", user_id=seller.id, date=dt_module.date(2026, 7, 20), shift_type=ShiftType.LONG)
    session.add(sched)
    session.flush()

    sale = ShiftSale(uuid="sale-1", department_id=dept.id, seller_id=seller.id, buyer_id=buyer.id, schedule_id=sched.id, asking_amount=Decimal("50.00"), expires_at=dt_module.datetime(2026, 7, 25, 0, 0))
    session.add(sale)
    session.flush()

    # Create a SETTLED ledger entry directly
    ledger = FinancialLedger(
        uuid="ledger-1",
        transaction_ref="txn-1",
        shift_sale_id=sale.id,
        from_user_id=seller.id,
        to_user_id=buyer.id,
        entry_type=EntryType.DEBIT,
        amount=Decimal("50.00"),
        status=LedgerStatus.SETTLED
    )
    session.add(ledger)
    session.commit()

    # Attempt to modify the settled ledger record
    ledger.amount = Decimal("100.00")
    with pytest.raises(ImmutableRecordException) as exc_info:
        session.flush()
    
    assert "Settled ledger records cannot be modified." in str(exc_info.value)
    session.close()

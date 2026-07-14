import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.base import Base
from app.models.department import Department
from app.models.user import User, UserRole
from app.models.schedule import Schedule, ShiftType, ScheduleSource
from app.models.financial_ledger import FinancialLedger, EntryType, LedgerStatus
from app.exceptions import ImmutableRecordException, ScheduleConflictException

def get_clean_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    return Session()

def test_department_defaults():
    """Verify default values on Department persist."""
    session = get_clean_session()
    dept = Department(uuid="dept-card-1", name="Cardiology", code="CARD")
    session.add(dept)
    session.commit()
    
    assert dept.monthly_target_hours == 160
    assert dept.hospital_name is None
    session.close()

def test_user_role_values():
    """Verify UserRole enum values and that SQLAlchemy maps role string correctly."""
    assert UserRole.NURSE.value == "nurse"
    assert UserRole.PARTNER.value == "partner"
    assert UserRole.ADMIN.value == "admin"

    session = get_clean_session()
    dept = Department(uuid="dept-test-role", name="Role Test", code="ROLE")
    session.add(dept)
    session.flush()

    user = User(uuid="user-role-1", department_id=dept.id, full_name="Role User", employee_id="EMP-R1", phone="07899999999", password="pw", role=UserRole.PARTNER)
    session.add(user)
    session.commit()

    assert user.role == UserRole.PARTNER
    assert user.role.value == "partner"
    session.close()

def test_schedule_defaults():
    """Verify default values on Schedule persist."""
    session = get_clean_session()
    # Need user first to satisfy foreign key
    dept = Department(uuid="dept-card-2", name="ICU", code="ICU")
    session.add(dept)
    session.flush()
    
    user = User(uuid="user-u1", department_id=dept.id, full_name="Nurse", employee_id="EMP-U1", phone="991", password="pw")
    session.add(user)
    session.flush()
    
    import datetime as dt_module
    sched = Schedule(uuid="sched-uuid", user_id=user.id, date=dt_module.date(2026, 7, 14), shift_type=ShiftType.LONG)
    session.add(sched)
    session.commit()
    
    assert sched.source == ScheduleSource.MANUAL
    assert sched.note is None
    session.close()

def test_financial_ledger_defaults():
    """Verify default values on FinancialLedger persist."""
    session = get_clean_session()
    dept = Department(uuid="dept-card-3", name="ICU", code="ICU")
    session.add(dept)
    session.flush()
    
    user = User(uuid="user-u2", department_id=dept.id, full_name="Nurse", employee_id="EMP-U2", phone="992", password="pw")
    session.add(user)
    session.flush()
    
    import datetime as dt_module
    sched = Schedule(uuid="sched-uuid-2", user_id=user.id, date=dt_module.date(2026, 7, 14), shift_type=ShiftType.LONG)
    session.add(sched)
    session.flush()
    
    from decimal import Decimal
    from app.models.shift_sale import ShiftSale
    sale = ShiftSale(uuid="sale-uuid", department_id=dept.id, seller_id=user.id, schedule_id=sched.id, asking_amount=Decimal("50.00"), expires_at=dt_module.datetime(2026, 7, 25, 0, 0))
    session.add(sale)
    session.flush()

    ledger = FinancialLedger(
        uuid="ledger-uuid",
        transaction_ref="tx-1",
        shift_sale_id=sale.id,
        from_user_id=user.id,
        to_user_id=user.id,
        entry_type=EntryType.CREDIT,
        amount=Decimal("100.00")
    )
    session.add(ledger)
    session.commit()
    
    assert ledger.currency == "IQD"
    assert ledger.status == LedgerStatus.UNSETTLED
    assert ledger.note is None
    session.close()

def test_custom_exceptions():
    """Verify custom exceptions can be raised with messages."""
    with pytest.raises(ImmutableRecordException) as exc_info:
        raise ImmutableRecordException("Settled ledger records cannot be modified.")
    assert "cannot be modified" in str(exc_info.value)

    with pytest.raises(ScheduleConflictException) as exc_info:
        raise ScheduleConflictException("Conflict detected on date 2026-07-14.")
    assert "Conflict detected" in str(exc_info.value)

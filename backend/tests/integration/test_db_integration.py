import pytest
import datetime as dt_module
from decimal import Decimal
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError
from app.models.base import Base
from app.models.department import Department
from app.models.user import User
from app.models.schedule import Schedule, ShiftType

def get_clean_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    return Session()

def test_relationship_cascades_user_deletion():
    """Verify that deleting a User cascades and soft/hard deletes their schedules."""
    session = get_clean_session()
    
    dept = Department(uuid="dept-1", name="ICU", code="ICU-1")
    session.add(dept)
    session.flush()

    user = User(
        uuid="user-1",
        department_id=dept.id,
        full_name="Test Nurse",
        employee_id="EMP-101",
        phone="07700000000",
        password="hashed_password"
    )
    session.add(user)
    session.flush()

    sched1 = Schedule(
        uuid="sched-1",
        user_id=user.id,
        date=dt_module.date(2026, 7, 14),
        shift_type=ShiftType.LONG
    )
    sched2 = Schedule(
        uuid="sched-2",
        user_id=user.id,
        date=dt_module.date(2026, 7, 15),
        shift_type=ShiftType.NIGHT
    )
    session.add_all([sched1, sched2])
    session.commit()

    # Verify relationships are loaded
    assert len(user.schedules) == 2

    # Delete User
    session.delete(user)
    session.commit()

    # Schedules should be cascade deleted because of cascade="all, delete-orphan"
    remaining_schedules = session.query(Schedule).all()
    assert len(remaining_schedules) == 0
    session.close()

def test_department_deletion_restricted_by_users():
    """Verify that deleting a Department with active users raises an IntegrityError."""
    session = get_clean_session()
    
    dept = Department(uuid="dept-2", name="Pediatrics", code="PED-1")
    session.add(dept)
    session.flush()

    user = User(
        uuid="user-2",
        department_id=dept.id,
        full_name="Pediatric Nurse",
        employee_id="EMP-102",
        phone="07700000001",
        password="hashed_password"
    )
    session.add(user)
    session.commit()

    # Deleting the department should fail due to RESTRICT foreign key constraint
    session.delete(dept)
    with pytest.raises(IntegrityError):
        session.commit()
    
    session.rollback()
    session.close()

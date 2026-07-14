import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.department import Department
from app.models.user import User, UserRole
from app.core.security import get_password_hash, create_access_token

@pytest.fixture
async def setup_dept_and_users(db_session: AsyncSession):
    dept = Department(uuid="dept-test-2", name="Surgery", code="SURG-01", monthly_target_hours=160)
    db_session.add(dept)
    await db_session.commit()
    await db_session.refresh(dept)

    hashed_pw = get_password_hash("password123")
    nurse_user = User(
        uuid="user-nurse-1",
        department_id=dept.id,
        full_name="Nurse Bob",
        employee_id="EMP-N1",
        phone="07700000010",
        password=hashed_pw,
        role=UserRole.NURSE
    )
    admin_user = User(
        uuid="user-admin-1",
        department_id=dept.id,
        full_name="Admin Alice",
        employee_id="EMP-A1",
        phone="07700000011",
        password=hashed_pw,
        role=UserRole.ADMIN
    )
    db_session.add_all([nurse_user, admin_user])
    await db_session.commit()

    nurse_token = create_access_token(subject=nurse_user.uuid)
    admin_token = create_access_token(subject=admin_user.uuid)
    return dept, nurse_token, admin_token

@pytest.mark.asyncio
async def test_list_and_get_departments(async_client: AsyncClient, setup_dept_and_users):
    dept, nurse_token, _ = setup_dept_and_users
    headers = {"Authorization": f"Bearer {nurse_token}"}

    list_res = await async_client.get("/api/v1/departments", headers=headers)
    assert list_res.status_code == 200
    departments = list_res.json()
    assert len(departments) >= 1
    assert any(d["uuid"] == dept.uuid for d in departments)

    get_res = await async_client.get(f"/api/v1/departments/{dept.uuid}", headers=headers)
    assert get_res.status_code == 200
    assert get_res.json()["code"] == "SURG-01"

@pytest.mark.asyncio
async def test_patch_department_as_nurse_forbidden(async_client: AsyncClient, setup_dept_and_users):
    dept, nurse_token, _ = setup_dept_and_users
    headers = {"Authorization": f"Bearer {nurse_token}"}

    payload = {"name": "Surgery Modified by Nurse"}
    response = await async_client.patch(f"/api/v1/departments/{dept.uuid}", json=payload, headers=headers)
    assert response.status_code == 403
    assert "Not enough privileges" in response.json()["detail"]

@pytest.mark.asyncio
async def test_patch_department_as_admin_success(async_client: AsyncClient, setup_dept_and_users):
    dept, _, admin_token = setup_dept_and_users
    headers = {"Authorization": f"Bearer {admin_token}"}

    payload = {"name": "Surgery Updated", "monthly_target_hours": 180}
    response = await async_client.patch(f"/api/v1/departments/{dept.uuid}", json=payload, headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Surgery Updated"
    assert data["monthly_target_hours"] == 180

@pytest.mark.asyncio
async def test_create_department_as_admin(async_client: AsyncClient, setup_dept_and_users):
    _, _, admin_token = setup_dept_and_users
    headers = {"Authorization": f"Bearer {admin_token}"}

    payload = {
        "name": "Radiology",
        "code": "RAD-01",
        "hospital_name": "General Hospital",
        "monthly_target_hours": 160
    }
    response = await async_client.post("/api/v1/departments", json=payload, headers=headers)
    assert response.status_code == 201
    assert response.json()["code"] == "RAD-01"
    assert "uuid" in response.json()

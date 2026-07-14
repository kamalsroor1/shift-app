import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.department import Department

@pytest.fixture
async def setup_department(db_session: AsyncSession) -> Department:
    dept = Department(uuid="dept-test-1", name="Emergency Room", code="ER-01", monthly_target_hours=160)
    db_session.add(dept)
    await db_session.commit()
    await db_session.refresh(dept)
    return dept

@pytest.mark.asyncio
async def test_register_user_success(async_client: AsyncClient, setup_department: Department):
    payload = {
        "full_name": "Nurse Sarah",
        "employee_id": "EMP-201",
        "phone": "07711223344",
        "email": "sarah@shiftsync.com",
        "password": "securepassword123",
        "department_code": "ER-01",
        "role": "nurse"
    }
    response = await async_client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["user"]["full_name"] == "Nurse Sarah"
    assert data["user"]["department_code"] == "ER-01"
    assert data["user"]["role"] == "nurse"
    assert "uuid" in data["user"]
    assert "id" not in data["user"]

@pytest.mark.asyncio
async def test_register_user_duplicate_conflict(async_client: AsyncClient, setup_department: Department):
    payload = {
        "full_name": "Nurse John",
        "employee_id": "EMP-202",
        "phone": "07711223355",
        "password": "securepassword123",
        "department_code": "ER-01",
        "role": "nurse"
    }
    res1 = await async_client.post("/api/v1/auth/register", json=payload)
    assert res1.status_code == 201

    res2 = await async_client.post("/api/v1/auth/register", json=payload)
    assert res2.status_code == 409
    assert "already exists" in res2.json()["detail"]

@pytest.mark.asyncio
async def test_login_and_me_success(async_client: AsyncClient, setup_department: Department):
    payload = {
        "full_name": "Nurse Ali",
        "employee_id": "EMP-301",
        "phone": "07800000001",
        "password": "mypassword456",
        "department_code": "ER-01"
    }
    reg_res = await async_client.post("/api/v1/auth/register", json=payload)
    assert reg_res.status_code == 201

    login_payload = {
        "phone_or_employee_id": "07800000001",
        "password": "mypassword456"
    }
    login_res = await async_client.post("/api/v1/auth/login", json=login_payload)
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]

    headers = {"Authorization": f"Bearer {token}"}
    me_res = await async_client.get("/api/v1/auth/me", headers=headers)
    assert me_res.status_code == 200
    assert me_res.json()["phone"] == "07800000001"

@pytest.mark.asyncio
async def test_login_invalid_credentials(async_client: AsyncClient, setup_department: Department):
    login_payload = {
        "phone_or_employee_id": "07999999999",
        "password": "wrongpassword"
    }
    response = await async_client.post("/api/v1/auth/login", json=login_payload)
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_protected_endpoint_without_token(async_client: AsyncClient):
    response = await async_client.get("/api/v1/auth/me")
    assert response.status_code == 401

@pytest.mark.asyncio
async def test_token_refresh(async_client: AsyncClient, setup_department: Department):
    payload = {
        "full_name": "Nurse Refresh",
        "employee_id": "EMP-401",
        "phone": "07800000002",
        "password": "mypassword456",
        "department_code": "ER-01"
    }
    reg_res = await async_client.post("/api/v1/auth/register", json=payload)
    assert reg_res.status_code == 201
    token = reg_res.json()["access_token"]

    headers = {"Authorization": f"Bearer {token}"}
    ref_res = await async_client.post("/api/v1/auth/refresh", headers=headers)
    assert ref_res.status_code == 200
    new_token = ref_res.json()["access_token"]
    assert new_token is not None

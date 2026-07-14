import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.department import Department
from app.models.user import User, UserRole
from app.core.security import get_password_hash, create_access_token

@pytest.fixture
async def setup_family_users(db_session: AsyncSession):
    dept = Department(uuid="dept-test-3", name="ICU", code="ICU-01", monthly_target_hours=160)
    db_session.add(dept)
    await db_session.commit()
    await db_session.refresh(dept)

    hashed_pw = get_password_hash("password123")
    nurse = User(
        uuid="user-nurse-f1",
        department_id=dept.id,
        full_name="Nurse Clara",
        employee_id="EMP-F1",
        phone="07811111111",
        password=hashed_pw,
        role=UserRole.NURSE
    )
    partner = User(
        uuid="user-partner-f1",
        department_id=dept.id,
        full_name="Partner David",
        employee_id="EMP-F2",
        phone="07822222222",
        password=hashed_pw,
        role=UserRole.PARTNER
    )
    intruder = User(
        uuid="user-intruder-f1",
        department_id=dept.id,
        full_name="Intruder Eve",
        employee_id="EMP-F3",
        phone="07833333333",
        password=hashed_pw,
        role=UserRole.PARTNER
    )
    db_session.add_all([nurse, partner, intruder])
    await db_session.commit()

    nurse_token = create_access_token(subject=nurse.uuid)
    partner_token = create_access_token(subject=partner.uuid)
    intruder_token = create_access_token(subject=intruder.uuid)
    return nurse, partner, intruder, nurse_token, partner_token, intruder_token

@pytest.mark.asyncio
async def test_family_link_lifecycle(async_client: AsyncClient, setup_family_users):
    nurse, partner, intruder, nurse_token, partner_token, intruder_token = setup_family_users

    # 1. Nurse initiates family link
    nurse_headers = {"Authorization": f"Bearer {nurse_token}"}
    init_payload = {"partner_phone": partner.phone}
    init_res = await async_client.post("/api/v1/family-links", json=init_payload, headers=nurse_headers)
    assert init_res.status_code == 201
    link_data = init_res.json()
    assert link_data["status"] == "PENDING"
    assert link_data["partner_user_uuid"] == partner.uuid
    assert link_data["primary_nurse_uuid"] == nurse.uuid
    link_uuid = link_data["uuid"]

    # 2. Intruder attempts to accept the link -> 403 Forbidden
    intruder_headers = {"Authorization": f"Bearer {intruder_token}"}
    intr_res = await async_client.patch(f"/api/v1/family-links/{link_uuid}/accept", headers=intruder_headers)
    assert intr_res.status_code == 403

    # 3. Partner lists family links and accepts
    partner_headers = {"Authorization": f"Bearer {partner_token}"}
    list_res = await async_client.get("/api/v1/family-links", headers=partner_headers)
    assert list_res.status_code == 200
    assert any(l["uuid"] == link_uuid for l in list_res.json())

    accept_res = await async_client.patch(f"/api/v1/family-links/{link_uuid}/accept", headers=partner_headers)
    assert accept_res.status_code == 200
    assert accept_res.json()["status"] == "ACTIVE"
    assert accept_res.json()["linked_at"] is not None

    # 4. Nurse revokes the link
    revoke_res = await async_client.delete(f"/api/v1/family-links/{link_uuid}", headers=nurse_headers)
    assert revoke_res.status_code == 200
    assert revoke_res.json()["status"] == "REVOKED"

    # 5. Nurse re-initiates the family link (tests reuse of revoked row to bypass database unique constraint)
    reinit_res = await async_client.post("/api/v1/family-links", json=init_payload, headers=nurse_headers)
    assert reinit_res.status_code == 201
    reinit_data = reinit_res.json()
    assert reinit_data["status"] == "PENDING"
    assert reinit_data["uuid"] != link_uuid  # UUID should be regenerated

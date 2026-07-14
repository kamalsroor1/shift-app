# TASK-012: Phase 2 Pytest API Integration Tests

> **Status:** `PENDING` | **Phase:** `Phase 2 — Authentication, Family Links & Department APIs` | **Owner:** `@qa-agent`

## 1. Objective & Scope
Create and execute a comprehensive async integration test suite (`tests/integration/test_auth_api.py`) using `pytest`, `pytest-asyncio`, and `httpx.AsyncClient` to rigorously test authentication, token verification, department CRUD, and family link lifecycle flows.

## 2. Requirements & Specifications

### Test Cases
1. **Authentication Tests:**
   - `test_register_user_success`: Register a new nurse and verify return tokens + UUID response.
   - `test_register_user_duplicate_phone_error`: Assert 409 Conflict when registering with duplicate phone or employee ID.
   - `test_login_success`: Verify login returns valid `access_token` and `user` profile with UUIDs.
   - `test_login_invalid_credentials`: Assert 401 Unauthorized for wrong password or unknown phone.
   - `test_protected_endpoint_without_token`: Assert 401 Unauthorized when requesting protected endpoints without Bearer header.

2. **Department API & RBAC Tests:**
   - `test_get_departments`: Assert authenticated user can list/get departments.
   - `test_patch_department_as_admin`: Assert `ADMIN` user can update department details.
   - `test_patch_department_as_nurse_forbidden`: Assert `NURSE` user receives 403 Forbidden when attempting to update department.

3. **Family Link API Tests:**
   - `test_family_link_lifecycle`:
     - Nurse initiates link with Partner phone (`POST /api/v1/family-links` -> `PENDING`).
     - Partner logs in and accepts link (`PATCH /api/v1/family-links/{uuid}/accept` -> `ACTIVE`).
     - Nurse revokes link (`DELETE /api/v1/family-links/{uuid}` -> `REVOKED`/deleted).
   - `test_accept_family_link_wrong_user_forbidden`: Assert third user cannot accept a link addressed to another partner.

## 3. Acceptance Criteria
1. All integration tests pass (`pytest tests/integration/test_auth_api.py -v` exits with code 0).
2. Tests execute against isolated test database sessions or rolled-back transactions using async test fixtures.

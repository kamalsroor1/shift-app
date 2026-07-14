# TASK-008: Implement Department API (CRUD for Admin)

> **Status:** `PENDING` | **Phase:** `Phase 2 — Authentication, Family Links & Department APIs` | **Owner:** `@backend-agent`

## 1. Objective & Scope
Implement Department CRUD API endpoints (`/api/v1/departments/*`) with role-based access control (RBAC), ensuring that only users with the `ADMIN` role can update department details or create new departments, while authenticated users can view department details.

## 2. Requirements & Specifications

### Architectural Design Patterns Required
- **DTO Pattern:** Define Pydantic v2 schemas (`DepartmentResponse`, `DepartmentCreateRequest`, `DepartmentUpdateRequest`) in `app/schemas/department.py`. All IDs exposed in schemas must be `uuid`.
- **Service Layer Pattern:** Encapsulate department query and update logic inside `app/services/department_service.py` (`DepartmentService`).
- **Dependency Injection Pattern:** Implement `verify_department_admin` dependency in `app/api/deps.py` that verifies `current_user.role == UserRole.ADMIN`.
- **Repository Pattern:** Perform database operations via SQLAlchemy `AsyncSession`.

### Endpoints
1. `GET /api/v1/departments`:
   - Accessible by any authenticated user.
   - Optional filtering by `code` or search query.
   - Returns list of `DepartmentResponse`.

2. `GET /api/v1/departments/{uuid}`:
   - Accessible by any authenticated user.
   - Looks up department by `uuid`. Returns 404 if not found.
   - Returns `DepartmentResponse`.

3. `PATCH /api/v1/departments/{uuid}`:
   - Protected by `Depends(verify_department_admin)`.
   - Admin can update `name`, `hospital_name`, `monthly_target_hours`, or `code`.
   - Returns 403 Forbidden if non-admin attempts to update.
   - Returns updated `DepartmentResponse`.

## 3. Acceptance Criteria
1. Non-admin user (e.g., `role == NURSE`) attempting to PATCH `/api/v1/departments/{uuid}` receives 403 Forbidden (`HTTPException(status_code=403, detail="Not enough privileges")`).
2. Admin user can successfully update department attributes.
3. UUID is used for endpoint paths and responses (`/api/v1/departments/{uuid}` instead of auto-increment integer IDs).

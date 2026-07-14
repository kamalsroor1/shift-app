# TASK-009: Implement Family Link API

> **Status:** `PENDING` | **Phase:** `Phase 2 — Authentication, Family Links & Department APIs` | **Owner:** `@backend-agent`

## 1. Objective & Scope
Implement the Family Link API (`/api/v1/family-links/*`) allowing nurses (`NURSE`) to initiate partner links with family members (`PARTNER`), partners to accept pending requests, and nurses to revoke active links.

## 2. Requirements & Specifications

### Architectural Design Patterns Required
- **DTO Pattern:** Define Pydantic v2 schemas (`FamilyLinkCreateRequest`, `FamilyLinkResponse`) in `app/schemas/family_link.py`. All references (`uuid`, `primary_nurse_uuid`, `partner_user_uuid`) must use UUIDs.
- **Service Layer Pattern:** Encapsulate family link lifecycle logic inside `app/services/family_link_service.py` (`FamilyLinkService`).
- **State Machine / Lifecycle Pattern:** Manage states: `PENDING` -> `ACTIVE` or `PENDING`/`ACTIVE` -> `REVOKED`/deleted.
- **Dependency Injection Pattern:** Protect endpoints using `get_current_active_user`.

### Endpoints
1. `POST /api/v1/family-links`:
   - Nurse initiates a link by providing the partner's phone number (`phone` or `partner_user_uuid`).
   - Looks up partner `User` by `phone`. If partner user does not exist yet or role is not `PARTNER`, handles cleanly (returns 404 or specific guidance/error or links existing partner).
   - Creates `FamilyLink` record with `status=LinkStatus.PENDING` and unique `uuid`.
   - Returns `FamilyLinkResponse`.

2. `PATCH /api/v1/family-links/{uuid}/accept`:
   - Partner user accepts the pending link initiated for them (`family_link.partner_user_id == current_user.id`).
   - Updates `status` from `PENDING` to `LinkStatus.ACTIVE`.
   - If user is not the designated partner or link is not pending, returns 403/400.
   - Returns updated `FamilyLinkResponse`.

3. `DELETE /api/v1/family-links/{uuid}` (or `PATCH .../revoke`):
   - Nurse (or partner) revokes an active or pending link (`family_link.primary_nurse_id == current_user.id` or `partner_user_id == current_user.id`).
   - Sets `status=LinkStatus.REVOKED` (or deletes record / soft deletes depending on data retention).
   - Returns 204 or `FamilyLinkResponse`.

4. `GET /api/v1/family-links`:
   - Returns all links where current user is primary nurse or partner user.

## 3. Acceptance Criteria
1. Full PENDING -> ACTIVE -> REVOKED flow works cleanly.
2. Partner cannot view nurse's schedule without an `ACTIVE` family link (this check will be enforced when viewing schedules).
3. Attempting to accept another user's family link returns 403 Forbidden.

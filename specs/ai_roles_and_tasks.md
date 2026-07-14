# ShiftSync — AI Agent Roles & SDD Task Breakdown
> **Status:** `ACTIVE` | **Version:** `2.0.0` | **Last Updated:** 2026-07-14  
> **Methodology:** Spec-Driven Development (SDD) via GitHub Spec Kit  
> **Trigger Command:** `/speckit.tasks`

---

## Overview

This document defines the autonomous AI agent team structure, their responsibilities, 
their operational boundaries, and the full numbered task list that drives the
ShiftSync implementation from zero to production-ready.

Each task is atomic, testable, and maps to exactly one agent's domain.
Tasks within the same phase may be parallelized where dependencies allow.

---

## Part 1: AI Agent Role Definitions

---

### Agent 1: Backend DB & API Agent
**Codename:** `@backend-agent`  
**Technology Domain:** Python 3.11+, FastAPI, SQLAlchemy 2.0, Alembic, Pydantic v2, Uvicorn, WebSockets/Redis

#### Responsibilities

- Author and execute all Alembic database migration revisions in the correct dependency order.
- Implement all SQLAlchemy 2.0 models (`DeclarativeBase`, `Mapped`, `mapped_column`) with relationships, indexes, enums, and immutability event listeners.
- Build all Pydantic v2 request/response validation schemas (`BaseModel`).
- Build all FastAPI authentication & authorization dependencies (`Depends(get_current_user)`).
- Implement all API routers under `app/api/v1/endpoints/`.
- Write all `Service` classes (`app/services/`) containing core business logic (routers remain thin).
- Implement the Shift Swap state machine and the Shift Sale lifecycle in dedicated service modules.
- Implement the double-entry financial ledger write operations, strictly within async/sync SQLAlchemy transaction contexts (`session.begin()`).
- Configure and implement FastAPI native WebSockets event broadcasting (`WebSocketManager`).
- Configure FCM push notifications via `firebase-admin` Python SDK.
- Write Python unit and integration tests (`pytest`, `pytest-asyncio`, `httpx.AsyncClient`) targeting >= 80% coverage on all service and state-machine logic.
- Maintain the FastAPI main app routing table (`app/api/v1/router.py`) with versioned prefixes.

#### Constraints

- Must NOT write any frontend code or Flutter-related artifacts.
- Must NOT perform financial state mutations outside an explicit database transaction block.
- Must NOT expose internal auto-increment `id` — use `uuid` in all API responses (`schemas`).
- Must validate that all department-scope queries include a `.where(Model.department_id == user.department_id)` clause.
- Implement the API using the following architectural design patterns:
  - **Dependency Injection Pattern** (FastAPI `Depends`)
  - **Service Layer Pattern** (separate `app/services/` for business logic)
  - **Repository / Data Mapper Pattern** (SQLAlchemy 2.0 ORM models and queries)
  - **Observer / Event Listener Pattern** (SQLAlchemy event hooks)
  - **DTO Pattern / Schema Validation** (Pydantic v2 schemas)
  - **Singleton Pattern** (App settings and engine configs)
  - **State Machine Pattern** (For ShiftSwap/ShiftSale lifecycle states)

#### Key Deliverables per Phase

| Phase | Deliverable |
|---|---|
| 1 | All Alembic migrations run cleanly; `alembic upgrade head` succeeds |
| 2 | Auth endpoints (`/api/v1/auth/*`) tested; family-link flow validated; department CRUD complete |
| 3 | Swap + Sale state machines pass all edge-case tests; ledger double-entry verified |
| 4 | Flutter Arabic-First RTL UI (Tokens, Welcome, Login, Interactive Calendar, EGP Ledger Cards) |
| 5 | Live API integration with Dio/Riverpod; real-time schedule & wallet updates |
| 6 | Real-Time WebSockets & FCM Push Notifications broadcasting swap/settlement events instantly |
| 7 | Admin Web Dashboard (ICU head management, complex swap approvals, and EGP financial audits) |
| 8 | Production Dockerization, GitHub Actions CI/CD Pipeline, and Cloud Deployment Readiness |
| 1–8 | OpenAPI (`/openapi.json`) and full UI documentation cleanly exported and verified |

---

### Agent 2: Frontend Flutter UI Agent
**Codename:** `@flutter-agent`  
**Technology Domain:** Flutter 3.22+, Dart 3.4+, Riverpod, Dio, Hive

#### Responsibilities

- Implement all design tokens in `lib/core/theme/app_tokens.dart`.
- Implement all reusable widgets in `lib/core/widgets/` (AppCard, ShiftBadge, StatusChip, LedgerCard, etc.).
- Implement all screen widgets under `lib/features/[feature]/presentation/screens/`.
- Implement Riverpod providers (StateNotifierProvider, FutureProvider, StreamProvider) for all feature state.
- Implement Dio-based repository classes for all API communication.
- Implement the interactive month-view calendar with tap-to-assign and batch-select logic.
- Implement the Ledger Wallet UI with DEBIT/CREDIT card rendering and settlement confirmation flow.
- Implement the Marketplace + Swap Board tabs with real-time refresh via WebSocket stream.
- Implement the bottom navigation shell and all screen routing.
- Implement local caching strategy using Hive for last-known schedule data (offline read).
- Write Flutter widget tests for all custom components targeting >= 70% coverage.

#### Constraints

- Must NOT hard-code any color, size, or spacing value — all values from `app_tokens.dart`.
- Must NOT use Provider, Bloc, GetX, or any state management library other than Riverpod.
- Must NOT use the raw `http` package — Dio only.
- Must NOT call APIs directly from widget `build()` methods — use Riverpod providers.
- The settlement action MUST show a confirmation bottom sheet before firing the API call.

#### Project Structure Convention

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_tokens.dart        ← Design tokens (colors, spacing, radius, shadows)
│   │   └── app_theme.dart         ← ThemeData configuration
│   ├── widgets/                   ← Shared reusable widgets
│   ├── network/
│   │   ├── dio_client.dart        ← Dio setup + interceptors
│   │   └── api_endpoints.dart     ← All endpoint strings as constants
│   └── utils/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── calendar/
│   ├── marketplace/
│   ├── swaps/
│   └── ledger/
│       ├── data/
│       │   ├── models/            ← Dart model classes (fromJson/toJson)
│       │   └── repositories/      ← Dio API calls
│       ├── domain/
│       │   └── providers/         ← Riverpod providers
│       └── presentation/
│           ├── screens/
│           └── widgets/
└── main.dart
```

---

### Agent 3: QA & Integration Agent
**Codename:** `@qa-agent`  
**Technology Domain:** Pytest, pytest-asyncio, httpx, Flutter Test, Integration Tests

#### Responsibilities

- Define and own the test plan matrix covering all critical business flows.
- Write Pytest integration tests for all API endpoints using `httpx.AsyncClient` and test database fixtures (`pytest-asyncio`).
- Write targeted Python unit tests for the Swap state machine and the Financial ledger double-entry logic.
- Write Flutter widget tests for `LedgerCard`, `ShiftBadge`, `StatusChip`, `AppCard`.
- Write Flutter integration tests for the Calendar assignment flow and the Settlement confirmation flow.
- Validate that concurrent swap acceptance attempts produce the correct outcome (one completes, one fails gracefully via optimistic locking).
- Validate that ledger settlement can ONLY be triggered by the `to_user_id` (creditor).
- Validate that department isolation is enforced: nurse in Department A cannot access Department B data.
- Maintain a `docs/test_coverage_report.md` updated after each phase.
- Run `pytest --cov=app` and `flutter test --coverage` at phase completion and gate progression.

#### Test Coverage Gates (must pass before next phase begins)

| Phase Complete | Minimum Coverage |
|---|---|
| After Phase 1 | DB constraints verified by Alembic migration tests |
| After Phase 2 | 80% coverage on Auth + Department service logic |
| After Phase 3 | 100% coverage of Swap state machine transitions; 100% of ledger double-entry |
| After Phase 4 | 70% Flutter widget test coverage on core Arabic RTL components & calendar |
| After Phase 5 | End-to-end integration tests pass for: login → schedule → post sale → purchase → settle |
| After Phase 6 | WebSocket reconnection resilience & FCM mock notification broadcast verified |
| After Phase 7 | Admin Web Dashboard RBAC permissions & audit report generation tested |
| After Phase 8 | Production Docker container spin-up & CI/CD pipeline pass on clean runners |

---

## Part 2: Task Breakdown

> Tasks are numbered sequentially. Phase boundaries are indicated.  
> Each task includes: ID, owning agent, dependency, and acceptance criteria.

---

### Phase 1: Foundation — Database Migrations & Models

**Goal:** A clean, versioned database with all SQLAlchemy models, relationships, and constraints in place.

---

**TASK-001** — `@backend-agent`  
**Title:** Initialize Python FastAPI project structure and configuration  
**Depends on:** None  
**Steps:**
1. Initialize virtual environment (`python -m venv venv` / `uv venv`).
2. Install foundational packages: `fastapi`, `uvicorn`, `sqlalchemy[asyncio]`, `alembic`, `pydantic`, `pydantic-settings`, `pymysql`, `aiomysql`, `python-jose`, `passlib[bcrypt]`, `pytest`, `pytest-asyncio`, `httpx`.
3. Configure `app/core/config.py` using `pydantic-settings` to load `.env` parameters (`DATABASE_URL`, `SECRET_KEY`, etc.).
4. Set up `app/db/session.py` with SQLAlchemy `async_engine` / `AsyncSession` factory.
5. Initialize Alembic (`alembic init alembic`) and configure `alembic.ini` + `alembic/env.py` to use `DATABASE_URL` and `Base.metadata`.

**AC:** FastAPI app starts cleanly with `uvicorn app.main:app --reload`; Alembic environment connects cleanly to MySQL.

---

**TASK-002** — `@backend-agent`  
**Title:** Create `departments` model and Alembic migration  
**Depends on:** TASK-001  
**Steps:**
1. Implement `Department` model in `app/models/department.py` per `specs/database_schema.md`.
2. Generate Alembic revision: `alembic revision --autogenerate -m "create departments table"`.
3. Verify unique constraints on `uuid` and `code`.

**AC:** `alembic upgrade head` creates table; duplicate `code` insertion raises IntegrityError.

---

**TASK-003** — `@backend-agent`  
**Title:** Create `users` model and Alembic migration  
**Depends on:** TASK-002  
**Steps:**
1. Implement `User` and `UserRole` enum in `app/models/user.py`.
2. Generate Alembic revision: `alembic revision --autogenerate -m "create users table"`.
3. Add foreign key to `departments.id` with `ondelete="RESTRICT"`.

**AC:** User creation succeeds; phone/employee_id uniqueness constraints enforced; relationship `user.department` loads cleanly.

---

**TASK-004** — `@backend-agent`  
**Title:** Create `schedules` model and Alembic migration  
**Depends on:** TASK-003  
**Steps:**
1. Implement `Schedule`, `ShiftType`, `ScheduleSource` in `app/models/schedule.py`.
2. Add `UniqueConstraint("user_id", "date", name="uq_schedules_user_date")`.
3. Generate Alembic revision: `alembic revision --autogenerate -m "create schedules table"`.
4. Create `ScheduleConflictException` in `app/exceptions.py`.

**AC:** Attempting to insert two active schedules for same user+date raises database unique constraint error.

---

**TASK-005** — `@backend-agent`  
**Title:** Create `family_links`, `shift_swaps`, `shift_sales`, `financial_ledger` models and migrations  
**Depends on:** TASK-004  
**Steps:**
1. Implement all four remaining SQLAlchemy models per spec.
2. Generate Alembic revision: `alembic revision --autogenerate -m "create remaining core tables"`.
3. Implement `FinancialLedger` immutability event listener in `app/models/financial_ledger.py`.

**AC:** All migrations run via `alembic upgrade head`; database has all 7 tables; updating a `SETTLED` ledger record raises `ImmutableRecordException`.

---

**TASK-006** — `@qa-agent`  
**Title:** Phase 1 database constraint and model tests (`pytest`)  
**Depends on:** TASK-005  
**Steps:**
1. Write Pytest database tests (`tests/unit/test_db_constraints.py`) using `pytest-asyncio` and test DB session.
2. Test `uq_schedules_user_date` constraint rejection.
3. Test ledger immutability event listener.

**AC:** All constraint tests pass; `pytest tests/unit/test_db_constraints.py` exits 0.

---

### Phase 2: Authentication, Family Links & Department APIs

**Goal:** Working auth system, user management, and family-link flow via authenticated FastAPI endpoints.

---

**TASK-007** — `@backend-agent`  
**Title:** Implement Auth API (Register, Login, Token Refresh)  
**Depends on:** TASK-005  
**Steps:**
1. Create Pydantic v2 schemas (`UserRegisterRequest`, `TokenResponse`, `UserResponse`) in `app/schemas/auth.py`.
2. Implement password hashing (`passlib`) and JWT creation (`python-jose`) in `app/core/security.py`.
3. Implement FastAPI auth dependency `get_current_active_user` in `app/api/deps.py`.
4. Implement endpoints in `app/api/v1/endpoints/auth.py`:
   - `POST /api/v1/auth/register`
   - `POST /api/v1/auth/login` (OAuth2PasswordRequestForm or JSON login)
   - `POST /api/v1/auth/refresh`

**AC:** Endpoints tested via Swagger UI (`/docs`); invalid login returns 401; protected endpoint with missing/invalid token returns 401.

---

**TASK-008** — `@backend-agent`  
**Title:** Implement Department API (CRUD for admin)  
**Depends on:** TASK-007  
**Steps:**
1. Implement dependency `verify_department_admin` in `app/api/deps.py`.
2. Endpoints in `app/api/v1/endpoints/departments.py`:
   - `GET /api/v1/departments`
   - `GET /api/v1/departments/{uuid}`
   - `PATCH /api/v1/departments/{uuid}`

**AC:** Non-admin nurse cannot PATCH department (returns 403); admin can; responses use UUID not internal `id`.

---

**TASK-009** — `@backend-agent`  
**Title:** Implement Family Link API  
**Depends on:** TASK-007  
**Steps:**
1. Endpoints in `app/api/v1/endpoints/family_links.py`:
   - `POST /api/v1/family-links` — nurse initiates link with partner's phone number.
   - `PATCH /api/v1/family-links/{uuid}/accept` — partner accepts link.
   - `DELETE /api/v1/family-links/{uuid}` — nurse revokes link.

**AC:** Full PENDING → ACTIVE → REVOKED flow testable; partner cannot view nurse's schedule without ACTIVE link.

---

**TASK-010** — `@flutter-agent`  
**Title:** Initialize Flutter project and implement design token system  
**Depends on:** None (parallel with Phase 2 backend)  
**Steps:**
1. `flutter create shiftsync_app --org com.shiftsync`
2. Add dependencies: `flutter_riverpod`, `dio`, `flutter_secure_storage`, `hive_flutter`, `google_fonts`.
3. Implement `app_tokens.dart` with all tokens from `specs/ui_ux_spec.md § 2`.
4. Implement `app_theme.dart` wiring tokens into `ThemeData`.
5. Implement `AppCard`, `ShiftBadge`, `StatusChip` widgets.

**AC:** `flutter run` shows a token demo screen; `flutter test` passes widget tests for all 3 base components.

---

**TASK-011** — `@flutter-agent`  
**Title:** Implement Auth screens (Login + Registration)  
**Depends on:** TASK-010  
**Steps:**
1. `LoginScreen` and `RegisterScreen` using `AppCard` containers.
2. `AuthRepository` with Dio calls to TASK-007 endpoints.
3. `AuthNotifier` (StateNotifierProvider) managing token + user state.
4. Store token in `flutter_secure_storage` on login; clear on logout.
5. Redirect to `/dashboard` on success; show error snackbar on failure.

**AC:** Login with valid credentials → Dashboard visible; login with wrong password → error displayed; token persists across app restarts.

---

**TASK-012** — `@qa-agent`  
**Title:** Phase 2 API integration tests (`pytest` + `httpx.AsyncClient`)  
**Depends on:** TASK-009  
**Steps:**
1. Async integration tests for Register, Login, Refresh.
2. Integration tests for family link lifecycle.
3. Assert department isolation across protected endpoints.

**AC:** `pytest tests/integration/test_auth_api.py` exits 0; >= 80% coverage on auth and family links service logic.

---

### Phase 3: Shift Swapping, Selling & Financial Ledger APIs

**Goal:** Complete transactional FastAPI backend for all shift trading and financial operations.

---

**TASK-013** — `@backend-agent`  
**Title:** Implement Schedule API (CRUD for nurse's own schedule)  
**Depends on:** TASK-007  
**Steps:**
1. Endpoints in `app/api/v1/endpoints/schedules.py`:
   - `GET /api/v1/schedules?month=2026-07` — returns nurse's schedule for a month.
   - `POST /api/v1/schedules` — create/update shift for a date (upsert pattern via `ScheduleService`).
   - `DELETE /api/v1/schedules/{uuid}` — soft delete (set to OFF or remove).
2. Authorize check: nurse can only modify own schedules; admin can modify dept schedules.
3. Validate: cannot modify a schedule that is part of an active swap or sale.

**AC:** Month query returns correct shift data; duplicate date upserts correctly; locked schedule returns 409 with descriptive message.

---

**TASK-014** — `@backend-agent`  
**Title:** Implement Shift Swap Engine  
**Depends on:** TASK-013  
**Steps:**
1. `ShiftSwapService` (`app/services/shift_swap_service.py`) — implements state machine (FR-SWAP-03).
2. Endpoints in `app/api/v1/endpoints/swaps.py`:
   - `POST /api/v1/swaps` — create swap proposal
   - `PATCH /api/v1/swaps/{uuid}/accept`
   - `PATCH /api/v1/swaps/{uuid}/confirm`
   - `PATCH /api/v1/swaps/{uuid}/reject`
   - `PATCH /api/v1/swaps/{uuid}/cancel`
   - `GET /api/v1/swaps` — list incoming + outgoing for current user
3. `COMPLETED` transition: wrap both schedule updates in `async with session.begin():`.
4. Broadcast WebSocket notification on every state transition.
5. Validate: max 3 active outgoing swaps (FR-SWAP-07).

**AC:** Full state machine tested; concurrent acceptance test (two requests simultaneously) — only one succeeds; expired swap handled cleanly.

---

**TASK-015** — `@backend-agent`  
**Title:** Implement Shift Sales Marketplace  
**Depends on:** TASK-013  
**Steps:**
1. `ShiftSaleService` (`app/services/shift_sale_service.py`) — implements listing, purchasing, cancellation lifecycle.
2. Endpoints in `app/api/v1/endpoints/marketplace.py`:
   - `GET /api/v1/marketplace` — dept-scoped active listings (`.where(ShiftSale.department_id == user.department_id)`)
   - `POST /api/v1/marketplace` — create listing
   - `POST /api/v1/marketplace/{uuid}/purchase` — buyer claims a listing
   - `DELETE /api/v1/marketplace/{uuid}` — seller cancels listing
3. `purchase()` method in service MUST use `async with session.begin():` wrapping:
   - Update `schedules` (reassign shift to buyer)
   - Update `shift_sales.status` to PURCHASED
   - Call `FinancialLedgerService.create_paired_entry(...)` (TASK-016)
4. Broadcast WebSocket notification on listing and purchase events.
5. Validate: seller cannot purchase own listing (FR-SALE-05); shift in active swap cannot be listed (FR-SALE-06).

**AC:** Purchase flow creates correctly updated schedules and two linked ledger rows; rollback test: if ledger write fails, sale remains LISTED and schedules unchanged.

---

**TASK-016** — `@backend-agent`  
**Title:** Implement Financial Ledger Service & Settlement API  
**Depends on:** TASK-015  
**Steps:**
1. `FinancialLedgerService.create_paired_entry(sale: ShiftSale, session: AsyncSession)`:
   - Generates shared `transaction_ref` UUID.
   - Inserts DEBIT row: `from_user=seller, to_user=buyer`.
   - Inserts CREDIT row: `from_user=buyer, to_user=seller`.
   - Both inserted in same database transaction as TASK-015.
2. Endpoints in `app/api/v1/endpoints/ledger.py`:
   - `GET /api/v1/ledger?type=debits|credits|history` — wallet data endpoint.
   - `PATCH /api/v1/ledger/{uuid}/settle` — settlement endpoint:
     - Authorize: `ledger.to_user_id == current_user.id` (ONLY creditor can settle).
     - Find paired record via `transaction_ref`.
     - Set `status=SETTLED`, `settled_at=datetime.utcnow()`, `settled_by=current_user.id` on both rows, inside transaction.
     - Broadcast WebSocket event to both parties.

**AC:** Settlement attempt by `from_user_id` returns 403; settlement by correct `to_user_id` marks both ledger rows SETTLED; subsequent settlement attempt on SETTLED record returns 409.

---

**TASK-017** — `@backend-agent`  
**Title:** Configure FastAPI WebSockets manager & FCM notifications  
**Depends on:** TASK-016  
**Steps:**
1. Implement `WebSocketManager` (`app/core/websockets.py`) managing active WebSocket connections scoped by `user_uuid` and `department_id`.
2. WebSocket endpoint `/api/v1/ws/{user_uuid}` authenticated via JWT token.
3. Configure FCM using `firebase-admin` Python SDK in `app/services/notification_service.py`.
4. Persist all sent notifications in database table.

**AC:** WebSocket client can connect and receive structured JSON events (`swap_status_changed`, `shift_purchased`, `debt_settled`); FCM payload format verified.

---

**TASK-018** — `@qa-agent`  
**Title:** Phase 3 — Swap state machine & ledger double-entry tests (`pytest`)  
**Depends on:** TASK-016  
**Steps:**
1. Unit test: all 7 state transitions of `ShiftSwapService` with valid + invalid inputs.
2. Unit test: `FinancialLedgerService.create_paired_entry()` always creates exactly 2 rows with correct fields.
3. Integration test: concurrent purchase race condition — simulate two buyers hitting `/purchase` simultaneously.
4. Integration test: settlement authorization — from_user cannot settle; to_user can.
5. Integration test: department isolation on marketplace GET.

**AC:** All tests pass; `pytest tests/integration/test_phase3.py` exits 0; swap state machine: 100% branch coverage; ledger: 100% branch coverage.

---

### Phase 4: Flutter UI Implementation

**Goal:** All screens built, designed, and functional with mocked/static data.

---

**TASK-019** — `@flutter-agent`  
**Title:** Implement Dashboard screen  
**Depends on:** TASK-011  
**Steps:**
1. `DashboardScreen` with greeting header, week snapshot row, hours widget, alert feed.
2. `HoursProgressPainter` — custom `CustomPainter` for circular hours widget.
3. `WeekSnapshotRow` — 7 `ShiftBadge` widgets mapped from this week's schedule.
4. `AlertFeedCard` — notification tile widget.
5. Wire to `DashboardProvider` (FutureProvider, initially with mock data).

**AC:** Dashboard renders with all sections; hours widget animates on first mount; week badges display correctly per shift type.

---

**TASK-020** — `@flutter-agent`  
**Title:** Implement Interactive Shift Calendar screen  
**Depends on:** TASK-010  
**Steps:**
1. `CalendarScreen` with month navigator and grid builder.
2. `CalendarGrid` — `GridView` with 7 columns, dynamic cell count per month.
3. `CalendarDayCell` — stateful, shows `ShiftBadge` or tap hint; handles tap/long-press.
4. `ShiftTypePickerSheet` — `DraggableScrollableSheet` with 3 shift type tiles + remove option.
5. Batch-select mode: toggle via header button; multi-cell selection with rubber-band gesture.
6. Month summary strip: sticky `SliverPersistentHeader` below grid.

**AC:** Tap empty cell → sheet appears → select type → badge appears with animation; long-press assigned cell → edit sheet; batch mode selects multiple cells correctly.

---

**TASK-021** — `@flutter-agent`  
**Title:** Implement Marketplace & Swap Board screens  
**Depends on:** TASK-010  
**Steps:**
1. `MarketplaceScreen` with `TabBar` (Marketplace | Swap Requests).
2. `ShiftSaleCard` — AppCard with left accent, shift info, purchase button.
3. `SwapCard` — incoming vs outgoing variants with correct action buttons.
4. `PostListingSheet` — bottom sheet to create a sale listing (shift date picker + amount input).
5. `SwapProposalSheet` — bottom sheet to propose a swap (select own shift + target colleague's shift).
6. Wire to mock `MarketplaceProvider` and `SwapProvider`.

**AC:** Both tabs render with mock data; purchase button disabled on own listing; swap accept/reject triggers mock state update; FAB opens correct sheet.

---

**TASK-022** — `@flutter-agent`  
**Title:** Implement Ledger Wallet screen  
**Depends on:** TASK-010  
**Steps:**
1. `LedgerScreen` with `TabBar` (I OWE | OWED TO ME | History).
2. Implement `LedgerCard` widget per spec (DEBIT red, CREDIT green).
3. `SettlementConfirmSheet` — bottom sheet with warning text and confirm/cancel buttons.
4. Animated card dismissal on settlement (slide-left + fade + success snackbar).
5. History tab: grayscale version of settled card.
6. Wire to mock `LedgerProvider`.

**AC:** Correct card colors per type; settlement sheet appears on button tap; mock settlement triggers card animation; history tab shows muted cards.

---

**TASK-023** — `@flutter-agent`  
**Title:** Implement Navigation Shell & Routing  
**Depends on:** TASK-019, TASK-020, TASK-021, TASK-022  
**Steps:**
1. `AppShell` — `Scaffold` with `NavigationBar` (4 items per spec).
2. `GoRouter` for declarative routing (add `go_router` dependency).
3. Implement route guard: unauthenticated users redirect to `/login`.
4. Marketplace tab badge: Riverpod provider drives unread listing count.

**AC:** Bottom nav switches screens; back button behavior correct; auth guard redirects correctly; badge updates when provider emits new count.

---

**TASK-024** — `@qa-agent`  
**Title:** Phase 4 Flutter widget tests  
**Depends on:** TASK-023  
**Steps:**
1. Widget tests for: `ShiftBadge` (all 3 types), `StatusChip` (all statuses), `LedgerCard` (DEBIT + CREDIT), `AppCard`.
2. Widget test: `CalendarDayCell` tap interaction.
3. Widget test: `SettlementConfirmSheet` — confirm and cancel tap paths.

**AC:** `flutter test` exits 0; >= 70% widget coverage on `lib/core/widgets/` and `lib/features/ledger/presentation/`.

---

### Phase 5: API Integration & Real-Time State Refresh

**Goal:** Flutter app fully connected to FastAPI backend; real-time updates working via WebSockets.

---

**TASK-025** — `@flutter-agent`  
**Title:** Implement Dio client with auth interceptor and base repository  
**Depends on:** TASK-017 (WebSockets running), TASK-011 (Auth token stored)  
**Steps:**
1. `DioClient` singleton via Riverpod Provider.
2. Request interceptor: attach `Authorization: Bearer {token}` header.
3. Response interceptor: handle 401 (redirect to login), 422 (parse FastAPI Pydantic validation errors), 500 (show global error snackbar).
4. `BaseRepository` abstract class with `safeCall()` wrapper returning `Either<Failure, T>`.

**AC:** Authenticated requests carry correct header; 401 response logs user out; 422 errors are shown as field-level form errors.

---

**TASK-026** — `@flutter-agent`  
**Title:** Connect Calendar screen to Schedule API  
**Depends on:** TASK-025, TASK-013  
**Steps:**
1. `ScheduleRepository` — Dio calls for GET month and POST/DELETE shift.
2. `ScheduleNotifier` (StateNotifierProvider) — manages `Map<DateTime, ShiftType>` state.
3. Replace mock data in `CalendarScreen` with real provider.
4. Hive caching: store last-fetched month schedule locally; use cache while loading.
5. On assignment, optimistic update + background API call; revert on failure.

**AC:** Calendar shows real schedule data after login; assignment persists after app restart; offline mode shows cached data with "Offline" indicator.

---

**TASK-027** — `@flutter-agent`  
**Title:** Connect Marketplace & Swap screens to APIs  
**Depends on:** TASK-025, TASK-014, TASK-015  
**Steps:**
1. `MarketplaceRepository`, `SwapRepository` — Dio calls for all endpoints.
2. Real-time WebSocket client (`web_socket_channel` connected to `/api/v1/ws/{user_uuid}`).
3. `MarketplaceNotifier` listens to WebSocket messages; refreshes listing on `shift_listed`/`shift_purchased` events.
4. `SwapNotifier` listens to WebSocket messages; updates swap status on `swap_status_changed` events.
5. Replace mock data in marketplace + swap screens with live providers.

**AC:** New listing posted by another nurse appears in real time (< 2s) without manual refresh; swap status update on recipient's phone triggers badge update on requester's phone.

---

**TASK-028** — `@flutter-agent`  
**Title:** Connect Ledger screen to Financial Ledger API  
**Depends on:** TASK-025, TASK-016  
**Steps:**
1. `LedgerRepository` — Dio calls for GET wallet data (debits/credits/history) and PATCH settle.
2. `LedgerNotifier` — manages wallet state; listens to `debt_settled` WebSocket event.
3. Replace mock data in `LedgerScreen` with live provider.
4. On `debt_settled` event: real-time card dismissal animation on BOTH parties' devices.

**AC:** Wallet shows correct IOU/claim data; settlement by creditor dismisses card on both devices in real time; settlement attempt by debtor is rejected by API (403 displayed as error toast).

---

**TASK-029** — `@flutter-agent`  
**Title:** Connect Dashboard to live data + notification stream  
**Depends on:** TASK-026, TASK-027, TASK-028  
**Steps:**
1. `DashboardProvider` (FutureProvider) — fetches week schedule + hours calculation from real API.
2. `NotificationProvider` (StreamProvider) — combines WebSocket events into unified alert feed.
3. Connect hours widget to real `total_hours` from API response.
4. Connect alert feed to `NotificationProvider` stream.

**AC:** Dashboard hours are accurate; new swap/sale/settlement events appear in alert feed without refresh.

---

**TASK-030** — `@qa-agent`  
**Title:** Phase 5 — End-to-end integration test suite  
**Depends on:** TASK-029  
**Steps:**
1. E2E test (Flutter integration_test + Pytest API integration): Login → Calendar assign shift → Post for sale → Second user purchases → Ledger shows IOU → Creditor settles → Ledger cleared.
2. E2E test: Login → Propose swap → Recipient accepts → Both confirm → Schedules swapped.
3. Backend integration test: department isolation — cross-dept API call returns 403.
4. Backend integration test: concurrent purchase race — exactly one buyer succeeds.

**AC:** All E2E tests pass; `flutter test integration_test/` exits 0; `pytest` exits 0; all Phase coverage gates met per `@qa-agent` coverage table.

---

### Phase 6: Real-Time WebSockets & Push Notifications

**TASK-031** — `@backend-architect`  
**Title:** Enhance WebSocket manager & implement FCM Push Notification broadcasting  
**Depends on:** TASK-017, TASK-028  
**Steps:**
1. Upgrade `WebSocketManager` in `app/services/websocket.py` with automatic reconnection handling and room isolation per department/ICU unit.
2. Integrate Firebase Cloud Messaging (FCM) admin SDK or HTTP v1 API to broadcast push alerts (`swap_requested`, `swap_accepted`, `debt_settled_egp`).
3. Ensure exact Egyptian Pound (`ج.م`) financial values are payload-embedded in push notifications.

**AC:** WebSocket channels withstand network drops; FCM notifications deliver under 1 second to offline medical staff.

---

**TASK-032** — `@flutter-agent`  
**Title:** Implement WebSocket Stream Manager & Background FCM Client in Flutter  
**Depends on:** TASK-031, TASK-027  
**Steps:**
1. Create `WebSocketStreamManager` provider in Riverpod with exponential backoff retry.
2. Connect the 4th Bottom Navigation tab (`الطلبات والإشعارات`) directly to live real-time streams and local notifications (`flutter_local_notifications`).
3. Render interactive push alerts allowing instant approval/rejection of shift swaps from the lock screen.

**AC:** Notifications tab updates instantly without refreshing; push alerts show clear Arabic medical copy and EGP amounts.

---

**TASK-033** — `@qa-agent`  
**Title:** Phase 6 Real-time resilience & notification delivery suite  
**Depends on:** TASK-032  
**Steps:**
1. Simulate network disconnects and assert automatic WebSocket re-subscription without data loss.
2. Validate mock FCM push delivery for cross-department shift swap attempts.

**AC:** Pytest and Flutter stream tests pass with 100% reliability.

---

### Phase 7: Admin Web Dashboard & Hospital Management

**TASK-034** — `@flutter-agent`  
**Title:** Build Admin Web Dashboard for ICU Heads (`Flutter Web`)  
**Depends on:** TASK-029, TASK-031  
**Steps:**
1. Create dedicated responsive Web layouts (`MainNavigationScaffold` expanded side-nav for desktop).
2. Implement Department Schedule Grid allowing head nurses to oversee all staff rosters simultaneously.
3. Build EGP Financial Ledger Audit screen to review total hospital shift exchange debts and settlement history.

**AC:** Admin dashboard renders cleanly on desktop browsers (`Microsoft Edge / Chrome`) with full Arabic right-to-left layout.

---

**TASK-035** — `@backend-architect`  
**Title:** Implement Admin Audit Logs & Comprehensive Analytics APIs  
**Depends on:** TASK-034  
**Steps:**
1. Create `/api/v1/admin/audit-logs` endpoint tracking every shift creation, swap approval, and financial settlement.
2. Create `/api/v1/admin/analytics/egp-summary` returning aggregated debt and settlement statistics per department.

**AC:** RBAC enforced strictly (`role == 'admin'`); endpoints return comprehensive analytics within 200ms.

---

**TASK-036** — `@qa-agent`  
**Title:** Phase 7 Admin RBAC & Audit report validation  
**Depends on:** TASK-035  
**Steps:**
1. Test role boundary: verify `nurse` token attempting to access `/api/v1/admin/*` receives immediate `403 Forbidden`.
2. Verify analytics accuracy by generating mock transactions and validating EGP totals.

**AC:** All security and analytical tests pass.

---

### Phase 8: Dockerization, CI/CD Pipelines & Production Deployment

**TASK-037** — `@devops-agent`  
**Title:** Production Dockerization (FastAPI, MySQL 8.0, Redis, Nginx)  
**Depends on:** TASK-035  
**Steps:**
1. Create optimized multi-stage `Dockerfile` for Python backend.
2. Create `docker-compose.prod.yml` orchestrating FastAPI, MySQL 8.0 with persistent volumes, Redis for WebSocket pub/sub, and Nginx reverse proxy with SSL termination.
3. Include health check scripts and automated startup seeding.

**AC:** `docker-compose -f docker-compose.prod.yml up -d` spins up all containers cleanly with zero errors.

---

**TASK-038** — `@devops-agent`  
**Title:** GitHub Actions CI/CD Pipeline (`ci-cd.yml`)  
**Depends on:** TASK-037  
**Steps:**
1. Create `.github/workflows/ci-cd.yml` running on every Push and Pull Request to `main`.
2. Pipeline jobs:
   - Backend Job: Setup Python, start MySQL service, run `manage.py test` (must pass 23/23 tests).
   - Flutter Job: Setup Flutter stable, verify formatting, run `flutter test` across all widget tests.
   - Build & Push Job: Build Docker images and tag with Git SHA upon successful merge.

**AC:** Pipeline runs automatically and blocks PR merges if any unit or widget test fails.

---

**TASK-039** — `@qa-agent` & `@devops-agent`  
**Title:** Production Readiness Audit & Smoke Testing  
**Depends on:** TASK-038  
**Steps:**
1. Execute full end-to-end smoke test against the Docker production environment.
2. Verify database backup and restore scripts.

**AC:** Production environment certified ready for live hospital deployment.

---

## Part 3: Task Summary Index

| Task | Agent | Phase | Title |
|---|---|---|---|
| TASK-001 | Backend | 1 | FastAPI project init + Alembic config |
| TASK-002 | Backend | 1 | departments model + Alembic migration |
| TASK-003 | Backend | 1 | users model + Alembic migration |
| TASK-004 | Backend | 1 | schedules model + Alembic migration |
| TASK-005 | Backend | 1 | Remaining 4 table models + migrations |
| TASK-006 | QA | 1 | Pytest DB constraint & model tests |
| TASK-007 | Backend | 2 | Auth API (Pydantic schemas + JWT) |
| TASK-008 | Backend | 2 | Department API |
| TASK-009 | Backend | 2 | Family Link API |
| TASK-010 | Flutter | 2 | Flutter init + design tokens |
| TASK-011 | Flutter | 2 | Auth screens |
| TASK-012 | QA | 2 | Phase 2 Pytest API integration tests |
| TASK-013 | Backend | 3 | Schedule API |
| TASK-014 | Backend | 3 | Shift Swap Engine |
| TASK-015 | Backend | 3 | Shift Sales Marketplace |
| TASK-016 | Backend | 3 | Financial Ledger + Settlement API |
| TASK-017 | Backend | 3 | WebSockets manager + FCM configuration |
| TASK-018 | QA | 3 | Phase 3 swap + ledger Pytest suite |
| TASK-019 | Flutter | 4 | Dashboard screen |
| TASK-020 | Flutter | 4 | Calendar screen |
| TASK-021 | Flutter | 4 | Marketplace + Swap screens |
| TASK-022 | Flutter | 4 | Ledger Wallet screen |
| TASK-023 | Flutter | 4 | Navigation shell + routing |
| TASK-024 | QA | 4 | Phase 4 widget tests |
| TASK-025 | Flutter | 5 | Dio client + base repository |
| TASK-026 | Flutter | 5 | Calendar API integration |
| TASK-027 | Flutter | 5 | Marketplace + Swap API integration |
| TASK-028 | Flutter | 5 | Ledger API integration + WebSocket |
| TASK-029 | Flutter | 5 | Dashboard live data + notifications |
| TASK-030 | QA | 5 | End-to-end integration tests |
| TASK-031 | Backend | 6 | Enhance WebSocket manager & FCM Push broadcasting |
| TASK-032 | Flutter | 6 | WebSocket Stream Manager & FCM Client in Flutter |
| TASK-033 | QA | 6 | Phase 6 Real-time resilience & notification suite |
| TASK-034 | Flutter | 7 | Admin Web Dashboard for ICU Heads (`Flutter Web`) |
| TASK-035 | Backend | 7 | Admin Audit Logs & Comprehensive Analytics APIs |
| TASK-036 | QA | 7 | Phase 7 Admin RBAC & Audit report validation |
| TASK-037 | DevOps | 8 | Production Dockerization (FastAPI, MySQL, Redis, Nginx) |
| TASK-038 | DevOps | 8 | GitHub Actions CI/CD Pipeline (`ci-cd.yml`) |
| TASK-039 | QA/DevOps | 8 | Production Readiness Audit & Smoke Testing |

---

## Part 4: Inter-Agent Communication Protocol

When one agent produces an artifact that another depends on:

1. **Backend → Flutter**: API contracts are documented via auto-generated OpenAPI (`/openapi.json`). Flutter agent reads this before building repositories.

2. **Flutter → QA**: Widget component list is maintained in `docs/component_manifest.md`. QA agent reads this to know which widgets to test.

3. **QA → All**: Coverage reports published to `docs/test_coverage_report.md`. Blocks next phase if gates are not met.

4. **Conflict Resolution**: If any agent detects a spec ambiguity, it raises an `OPEN_QUESTION` comment in the relevant spec file and pauses the task until the project owner resolves it.

---

## Part 5: Known Bugs Fixed, Root Causes & Mandatory Rules for Future Agents

> [!IMPORTANT]
> Every agent that touches the backend or Postman collection **MUST** read this section before starting work.
> These are real production bugs that were discovered and fixed — violating these rules will reintroduce them.

---

### BUG-001: Admin User Never Seeded When All Departments Already Exist

**File:** `backend/app/main.py` → `lifespan()` | `backend/manage.py` → `db:seed`

**Root Cause:**
The seeding loop builds a `first_dept` variable to use as the admin's department.
It only gets assigned during the loop **if a new department is created or found for the first time**.
When the server restarts and all 4 departments already exist, `first_dept` can stay `None`
if the loop logic short-circuits — causing the admin user to never be created or updated.
The `except Exception: pass` block silently swallowed the failure.

**Fix Applied:**
```python
# After the departments loop, always add this fallback:
if not first_dept:
    first_dept = await db.scalar(select(Department).limit(1))
```

**Self-Healing Rule:**
The admin seeding block MUST also handle the case where the admin already exists
by **resetting the password, role, and deleted_at** on every startup:
```python
elif existing_admin:
    existing_admin.password = get_password_hash("AdminSecret123!")
    existing_admin.role = UserRole.ADMIN
    existing_admin.deleted_at = None
    await db.commit()
```

**Never use `except Exception: pass` in seeding code.** Always log:
```python
except Exception as e:
    logging.getLogger(__name__).warning(f"[Lifespan Seed] Error: {e}")
```

**Symptom If Broken:** `POST /api/v1/auth/login` with admin credentials returns `401 Incorrect credentials`

**Quick Fix:** Run `python manage.py db:seed` to force re-seed.

---

### BUG-002: `LookupError: 'nurse' is not among defined enum values` on MySQL

**File:** `backend/app/models/user.py`

**Root Cause:**
SQLAlchemy's `Enum(UserRole)` on MySQL uses **member names** (`NURSE`, `PARTNER`, `ADMIN`) as the
valid values for the MySQL ENUM column, but the Python enum stores **values** (`nurse`, `partner`, `admin`).
When SQLAlchemy tries to map a row from MySQL back to Python, it compares the stored string `'nurse'`
against `['NURSE', 'PARTNER', 'ADMIN']` and raises `LookupError`.
This does **not** appear in SQLite (used in tests) — only in MySQL (used in production/local server).

**Fix Applied:**
```python
role: Mapped[UserRole] = mapped_column(
    Enum(UserRole, values_callable=lambda obj: [e.value for e in obj]),
    default=UserRole.NURSE,
    nullable=False
)
```

**Rule for Future Agents:**
Any `Enum` column on a model that uses a Python `str, enum.Enum` class with lowercase values
**MUST** include `values_callable=lambda obj: [e.value for e in obj]` to ensure MySQL compatibility.

**Symptom If Broken:** `POST /api/v1/auth/register` returns `500 Internal Server Error`
with `LookupError: 'nurse' is not among the defined enum values` in the server logs.

---

### BUG-003: `IntegrityError` on Family Link Re-Initiation After Revocation

**File:** `backend/app/services/family_link_service.py` → `initiate_link()`

**Root Cause:**
The `family_links` table has a `UniqueConstraint("primary_nurse_id", "partner_user_id", name="uq_family_links_pair")`.
When a nurse revokes a link and then tries to initiate a new one with the same partner,
the old row still exists (with `status=REVOKED`).
Attempting to `INSERT` a new row for the same pair violates the unique constraint and raises
`sqlalchemy.exc.IntegrityError`, which is **not caught** → becomes `500 Internal Server Error`.

**Fix Applied:**
Instead of inserting a new row, **reuse and reset the existing revoked row**:
```python
check_stmt = select(FamilyLink).where(
    (FamilyLink.primary_nurse_id == nurse.id) & (FamilyLink.partner_user_id == partner.id)
)
existing = await db.scalar(check_stmt)
if existing:
    if existing.status != FamilyLinkStatus.REVOKED:
        raise HTTPException(status_code=409, detail="An active or pending family link already exists")
    else:
        # Reuse the row — reset status, generate new UUID
        existing.status = FamilyLinkStatus.PENDING
        existing.uuid = str(uuid.uuid4())
        existing.linked_at = None
        existing.created_at = datetime.now()
        await db.commit()
        return ...
```

**Rule for Future Agents:**
Any service that creates rows in tables with composite unique constraints
**MUST** check for existing rows first (including soft-deleted or revoked ones)
and **reuse/update** them rather than blindly inserting.

**Symptom If Broken:** `POST /api/v1/family-links` returns `500 Internal Server Error`
after a previous link between the same nurse+partner was revoked.

---

### RULE-001: Postman Collection — Mandatory Role-Isolated JWT Tokens

**File:** `postman/shiftsync_postman_collection.json` | `postman/shiftsync_postman_environment.json`

**Problem:**
Using a single shared `access_token` variable across all requests in the collection
causes token overwriting between roles. When Admin login runs after Nurse login,
the admin token overwrites `access_token`. If admin login then fails,
all downstream admin-protected requests run with the nurse's token and return `403 Forbidden`.

**Mandatory Pattern — 3 Separate Token Variables:**

| Variable Name | Set By | Used By |
|---|---|---|
| `nurse_access_token` | Login as Nurse test script | `/me`, `/family-links`, nurse-only endpoints |
| `admin_access_token` | Login as Admin test script | `POST /departments`, `PATCH /departments/*` |
| `partner_access_token` | Login as Partner test script | `PATCH /family-links/{uuid}/accept` |

**Login Test Script Template:**
```javascript
// Login as Nurse
var json = pm.response.json();
if (json.access_token) {
    pm.environment.set("nurse_access_token", json.access_token);
    pm.environment.set("access_token", json.access_token); // fallback compat
}
```

**Request Auth Header Template:**
```text
// For nurse-only endpoints:
Authorization: Bearer {{nurse_access_token}}

// For admin-only endpoints:
Authorization: Bearer {{admin_access_token}}

// For partner-only endpoints:
Authorization: Bearer {{partner_access_token}}
```

**Rule:**
Every new endpoint added to the Postman collection MUST specify which role token it uses
in its `auth.bearer` block. **Never use a generic `{{access_token}}` for role-protected endpoints.**

---

### RULE-002: Postman Collection — link_uuid Must Be Saved from Create Response

**Problem:**
If the family-link initiation request fails or is skipped, `link_uuid` stays empty.
The Accept and Revoke requests then construct URLs like `/api/v1/family-links//accept`
which returns `404 Not Found` or `405 Method Not Allowed`.

**Mandatory Pattern:**
```javascript
// In the "Initiate Family Link" test script:
if (pm.response.code === 201) {
    var json = pm.response.json();
    pm.environment.set("link_uuid", json.uuid);
}
```

**Accept/Revoke URLs must be:**
```
PATCH {{base_url}}/api/v1/family-links/{{link_uuid}}/accept
DELETE {{base_url}}/api/v1/family-links/{{link_uuid}}
```

---

### RULE-003: Postman Body Mode Must Always Include JSON Language Metadata

**Problem:**
In some Postman versions/runners, a `"mode": "raw"` body without
`"options": {"raw": {"language": "json"}}` causes the request body to be dropped silently,
resulting in `422 Unprocessable Entity` or `500 Internal Server Error`.

**Mandatory Pattern for every request body:**
```json
"body": {
    "mode": "raw",
    "raw": "{ ... }",
    "options": {
        "raw": {
            "language": "json"
        }
    }
}
```

---

### RULE-004: Postman Refresh Token Flow

**Important API Contract:**
The `POST /api/v1/auth/refresh` endpoint does **NOT** accept a `refresh_token` in the request body.
It uses the existing **access token** passed as `Authorization: Bearer {{nurse_access_token}}`.
It re-issues a new access token for the same user.

**Correct refresh request:**
```
POST /api/v1/auth/refresh
Authorization: Bearer {{nurse_access_token}}
Body: {} (empty)
```

**DO NOT** expect a `refresh_token` field in the login response — the API does not return one.

---

### RULE-005: Admin Credentials Are Fixed

The system admin account is always seeded with these credentials. **Do not change them** in tests or environments:

| Field | Value |
|---|---|
| Phone (`admin_phone`) | `07800000000` |
| Password (`admin_password`) | `AdminSecret123!` |
| Employee ID | `ADM-001` |
| Role | `admin` |
| UUID | `user-super-admin-01` |

If admin login fails with `401`, run:
```powershell
python manage.py db:seed
```
Then restart the server. The `lifespan()` on startup will also self-heal the admin account.

---

### RULE-006: Tests Must Pass Before Git Push

**Non-negotiable rule:**
`python manage.py test` must return `[SUCCESS] All test suites passed successfully!`
before any commit is pushed to `main`. This applies to:

- Any change to `app/models/`
- Any change to `app/services/`
- Any change to `app/api/`
- Any change to `app/main.py`
- Any new migration in `alembic/versions/`

If a bug only manifests on MySQL (not SQLite used in tests),
a **diagnostic scratch script** must be written and run against the local MySQL database
to confirm the fix before pushing.

---

### RULE-007: Arabic-First / RTL-Default Application Architecture (`@flutter-agent`)

**Non-negotiable rule for all UI development:**
ShiftSync is an **Arabic-First** medical and financial shift management system designed primarily for Arabic-speaking healthcare personnel and hospitals.

1. **Mandatory Localization (`Locale('ar')`)**:
   - The Flutter app MUST be configured with `Locale('ar')` as its primary/default locale in `MaterialApp`.
   - `flutter_localizations` delegates (`GlobalMaterialLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`) MUST be included.
   - All UI layouts must naturally render **Right-to-Left (RTL)**.

2. **Typography (`Cairo` / `Tajawal`)**:
   - Do not use English fonts like `Inter` as the primary UI font.
   - The typography token (`AppTextStyles`) MUST use `GoogleFonts.cairo()` or `GoogleFonts.tajawal()` to ensure elegant, highly legible Arabic character rendering for medical schedules and financial numbers.

3. **Directional Accent Bars (`AppCard`)**:
   - Card accent indicator bars (`accentColor` in `AppCard`) MUST adapt to directional reading.
   - In RTL (`Directionality.of(context) == TextDirection.rtl`), the vertical colored accent bar must render on the **Right Edge** (leading side) of the card instead of the left.

4. **Terminology & Copywriting**:
   - All screen titles, buttons, labels, and financial descriptions MUST use clear, professional, and accessible medical Arabic terminology (e.g., "الورديات القادمة", "وردية صباحية طويلة", "سهر ليلي", "عليا فلوس (I OWE)", "ليا فلوس (OWED TO ME)", "طلب تبديل وردية", "سجل التبادلات والمحافظ").



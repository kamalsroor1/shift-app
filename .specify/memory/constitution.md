# ShiftSync — Project Constitution
> **Status:** `RATIFIED` | **Version:** `2.0.0` | **Last Updated:** 2026-07-14
>
> This document defines the non-negotiable architectural, quality, and behavioral
> principles governing every decision made on the ShiftSync project. All AI agents,
> contributors, and reviewers MUST treat these rules as inviolable constraints.
> Deviations require a formal ADR (Architecture Decision Record) and explicit
> project-owner sign-off.

---

## § 1 — Technology Stack Boundaries

| Layer | Technology | Constraint |
|---|---|---|
| **Backend Runtime** | Python 3.11+ / FastAPI | High-performance async REST API using Pydantic v2 & Uvicorn |
| **Backend Database** | MySQL 8.0+ | All data must be relational and transactional; accessed via async/sync SQLAlchemy 2.0 |
| **Backend Migrations** | Alembic | All schema changes must be versioned through Alembic migrations |
| **Backend Realtime** | FastAPI WebSockets + Redis Pub/Sub | Real-time bidirectional communication via WebSockets (or Pusher fallback) |
| **Backend Tasks/Queue** | BackgroundTasks / ARQ (Redis) | All async/heavy background jobs processed outside the main HTTP request-response cycle |
| **Mobile Frontend** | Flutter 3.22+ (Dart 3.4+) | Target: Android first; iOS-ready (no platform-only APIs without abstraction) |
| **State Management** | Riverpod (flutter_riverpod) | No Provider, Bloc, or GetX; Riverpod only for consistency |
| **HTTP Client** | Dio (Flutter) | Axios-style interceptors for auth tokens; no raw `http` package |
| **Local Storage** | flutter_secure_storage (tokens), Hive (local cache) | No SQLite for app data; Hive for offline caching only |

### 1.1 Prohibited Technologies

The following are explicitly **BANNED** unless a formal ADR overrides this entry:

- No PHP / Laravel or Node.js backend components
- No Django / Flask (FastAPI is the sole backend web framework)
- No GraphQL (REST-only API surface)
- No Retrofit-style generated clients on frontend (use Dio repositories manually)
- No `get_it` or `injectable` DI libraries in Flutter (Riverpod handles DI)
- No payment gateway SDK (financial ledger is internal only, no real money transfer)
- No raw SQL queries without SQLAlchemy parameter bindings (`text()`)

---

## § 2 — API Design Principles

1. **RESTful, versioned API**: All endpoints live under `/api/v1/`. Future versions are additive, not breaking.
2. **JSON Envelope & Pydantic v2**: All request and response bodies must be strictly validated using Pydantic v2 models following a standard envelope format:

```json
{ "data": {}, "meta": {}, "message": "string", "status": 200 }
```

3. **OAuth2 + JWT Authentication**: OAuth2 with Password Bearer or JWT access/refresh tokens (`python-jose` / `PyJWT`).
4. **Rate Limiting**: Apply `slowapi` rate limiting (`60/minute` on auth endpoints; `300/minute` on data routes).
5. **Strict HTTP verbs**: GET reads, POST creates, PUT/PATCH updates, DELETE soft-deletes.
6. **Never expose raw IDs**: Use UUIDs (`uuid` column) as the public identifier; internal auto-increment `id` stays private.
7. **OpenAPI Documentation**: Fully leverage FastAPI's auto-generated OpenAPI/Swagger schema at `/docs`.

---

## § 3 — Database & Data Integrity Rules

**RULE 3.1 — ACID Transactions are mandatory** for any operation that touches more than one table or changes financial state. All database sessions must use transaction context managers (`async with session.begin():` or `with session.begin():`).

**RULE 3.2 — Soft Deletes only** on `users`, `schedules`, `shift_swaps`, `shift_sales`, and `financial_ledger`. Hard deletes are forbidden on these entities (`deleted_at` timestamp check).

**RULE 3.3 — Optimistic Locking** (`updated_at` timestamp check) must guard all shift swap/sale state transitions to prevent race conditions.

**RULE 3.4 — Double-Entry Ledger**: Every financial event creates exactly two `financial_ledger` rows: one debit, one credit. The ledger is **append-only**; no UPDATE or DELETE on settled records enforced via SQLAlchemy `before_update` event hooks.

**RULE 3.5 — Unique Shift Constraint**: A nurse CANNOT have two active (non-deleted) schedule records on the same `date`. Enforced at both database (`UNIQUE(user_id, date)`) and application validation layers.

**RULE 3.6 — Department Isolation**: All query statements for swaps, sales, and marketplace listings MUST filter by `department_id`. Cross-department data access is a strict security violation.

---

## § 4 — UI / Design System Principles

1. **Single Design System**: All UI components derive from the token system defined in `specs/ui_ux_spec.md`. No ad-hoc colors or sizes inline in widget code.
2. **Minimalist Light Theme**: Default and only theme. Dark mode is a future milestone, not in scope.
3. **Rounded Cards**: All card-type widgets use `BorderRadius.circular(16)`. No sharp corners on elevated surfaces.
4. **Soft Shadows**: `BoxShadow` with `blurRadius: 12, offset: Offset(0, 4), color: Color(0x1A000000)`. No hard `elevation`-only shadows.
5. **High-Contrast Shift Badges**: Shift-status indicators must meet WCAG AA contrast ratio (4.5:1 minimum) against their card background.
6. **No External UI Kits**: All widgets are bespoke, built from Flutter core widgets.
7. **Responsive Layouts**: All screens must render correctly on screen widths 360dp–430dp (phones). Tablet layout is out of scope for v1.

---

## § 5 — Code Quality Standards

| Standard | Rule |
|---|---|
| **Flutter Linting** | `flutter_lints` + custom `analysis_options.yaml`; zero warnings policy |
| **Python Linting & Typing** | `ruff` for formatting & linting; `mypy` / `pyright` with strict type annotations (`def get_user(id: int) -> User:`) |
| **Test Coverage Targets** | Backend: >= 80% coverage via `pytest` and `pytest-asyncio`; Flutter: >= 70% widget tests |
| **Naming Convention (DB)** | `snake_case` for all columns and tables |
| **Naming Convention (Dart)** | `camelCase` vars/methods, `PascalCase` classes, `snake_case` files |
| **Naming Convention (Python)** | `PascalCase` classes (SQLAlchemy/Pydantic), `snake_case` variables/functions/files |
| **Function Length** | Max 40 lines per function/method; extract helper functions aggressively |
| **Commit Convention** | Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `chore:` |

---

## § 6 — Security Principles

1. **Input Validation**: Every API request is strictly validated via Pydantic v2 schemas (`BaseModel`).
2. **Authorization & Dependency Injection**: Every protected controller action relies on FastAPI dependencies (`Depends(get_current_user)`, `Depends(verify_department_member)`).
3. **SQL Injection Prevention**: SQLAlchemy 2.0 ORM (`select()`, `insert()`, `update()`) only.
4. **No Secrets in Codebase**: All settings loaded via `pydantic-settings` from `.env`. `.env` is gitignored. A `.env.example` is always kept current.

---

## § 7 — Realtime & Notification Rules

1. **FastAPI WebSockets + Redis Pub/Sub** for in-app real-time event broadcasting (new swap offers, marketplace posts, settlement confirmations).
2. **Private Channels** are mandatory for user-specific notifications (`/ws/user/{user_uuid}`).
3. **FCM Push Notifications** via `firebase-admin` Python SDK for background app state.
4. All realtime events must also persist in the database notifications table for auditability.

---

## § 8 — Versioning & Milestones

| Milestone | Scope |
|---|---|
| **v0.1 — Foundation** | Alembic Migrations, SQLAlchemy Models, Auth API (`/api/v1/auth/*`), Department & User CRUD |
| **v0.2 — Calendar** | Schedule input/output API + Flutter calendar UI |
| **v0.3 — Swaps** | Shift swap engine (request → accept/reject → confirm) |
| **v0.4 — Marketplace** | Shift selling, purchasing, ledger creation |
| **v0.5 — Ledger & Settlement** | Ledger wallet UI, settlement flow, balance calculations |
| **v1.0 — Production** | Realtime WebSockets integration, FCM, QA coverage gates met |

---

*This constitution is maintained by the project owner. Changes require a PR with a description of why the principle needs amendment.*

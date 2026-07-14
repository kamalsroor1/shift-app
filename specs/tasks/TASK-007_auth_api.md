# TASK-007: Implement Auth API (Register, Login, Token Refresh)

> **Status:** `ACTIVE` | **Phase:** `Phase 2 — Authentication, Family Links & Department APIs` | **Owner:** `@backend-agent`

## 1. Objective & Scope
Implement complete authentication endpoints (`/api/v1/auth/register`, `/api/v1/auth/login`, `/api/v1/auth/refresh`), JWT generation and verification, password hashing, and dependency injection helpers for extracting and verifying the current active user from Bearer tokens.

## 2. Requirements & Specifications

### Architectural Design Patterns Required
- **DTO Pattern / Schema Validation:** Define Pydantic v2 models in `app/schemas/auth.py` (`UserRegisterRequest`, `UserLoginRequest`, `TokenResponse`, `UserResponse`). Ensure external responses expose `uuid` and never internal primary key `id`.
- **Service Layer Pattern:** Encapsulate core registration, authentication, and token issuance logic inside `app/services/auth_service.py` (`AuthService`).
- **Dependency Injection Pattern:** Implement `get_db` (or verify it exists in `app/api/deps.py`) and `get_current_user` / `get_current_active_user` in `app/api/deps.py` using FastAPI `Depends`.
- **Repository Pattern:** Query and mutate `User` and `Department` models via SQLAlchemy 2.0 `AsyncSession`.
- **Singleton Pattern:** Use app `settings` from `app/core/config.py` for JWT secret keys, algorithms, and expiration timeouts.

### Endpoints
1. `POST /api/v1/auth/register`:
   - Accepts `UserRegisterRequest` (full_name, employee_id, phone, email, password, department_code, role [default NURSE]).
   - Looks up `Department` by `department_code`. Returns 404/400 if department not found.
   - Verifies phone, employee_id, and email are unique across `User`. Returns 409 (`HTTPException(status_code=409, detail=...)`) if conflict exists.
   - Hashes password using `passlib` bcrypt and creates user with generated `uuid` string.
   - Returns `TokenResponse` with access token, refresh token (optional/if needed or just access token + user info), and `UserResponse`.

2. `POST /api/v1/auth/login`:
   - Supports both `OAuth2PasswordRequestForm` (standard OAuth2 form where `username` can be phone or employee_id) or JSON login request (`phone` or `employee_id` plus `password`).
   - Verifies user credentials. Returns 401 (`HTTPException(status_code=401, detail="Incorrect credentials")`) if invalid or user soft-deleted (`deleted_at is not None`).
   - Returns `TokenResponse` (`access_token`, `token_type="bearer"`, `user`).

3. `POST /api/v1/auth/refresh`:
   - Verifies existing token or refresh token and issues a fresh `TokenResponse`.

## 3. Acceptance Criteria
1. Password verification securely checks hashed passwords (`passlib.context.CryptContext`).
2. `get_current_active_user` correctly decodes JWT, queries `User` by UUID or ID, verifies not deleted, and raises 401 Unauthorized if invalid or missing token.
3. Registration returns 409 on duplicate phone number or employee ID.
4. User responses strictly return `uuid` (never internal `id`).

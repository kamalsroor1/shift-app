# TASK-002: Create `departments` Model and Alembic Migration

> **Status:** `COMPLETED` | **Phase:** `Phase 1 — Foundation` | **Owner:** `@backend-agent`

## 1. Objective & Scope
Define the `Department` SQLAlchemy 2.0 model corresponding to Table 1 (`departments`) in `specs/database_schema.md` and generate its initial Alembic migration revision.

## 2. Requirements & Specifications
### Table Specification (`departments`)
| Column | Type | Attributes | Description |
|---|---|---|---|
| `id` | BigInteger | PK, Autoincrement | Internal primary key (dual-variant integer support for SQLite) |
| `uuid` | String(36) | Unique, Not Null, Indexed | External public reference UUID |
| `name` | String(150) | Not Null | Department display name |
| `code` | String(20) | Unique, Not Null | Department abbreviation code (e.g., ER-01) |
| `hospital_name` | String(150) | Nullable | Name of hospital/medical facility |
| `monthly_target_hours` | SmallInteger | Default: 160, Not Null | Expected monthly shift hours per nurse |
| `created_at` | DateTime | Default: `CURRENT_TIMESTAMP` | Creation timestamp |
| `updated_at` | DateTime | Default: `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Last update timestamp |

## 3. Acceptance Criteria
1. `Department` class inherits from `Base` and maps cleanly to `departments` table.
2. Alembic migration file `b42553576ae2_create_departments_table.py` accurately defines `op.create_table` with primary key, unique constraints (`uq_departments_uuid`, `uq_departments_code`), and indices.
3. Dual-database compatibility: `BigInteger().with_variant(Integer, "sqlite")` ensures SQLite in-memory unit tests autoincrement correctly.

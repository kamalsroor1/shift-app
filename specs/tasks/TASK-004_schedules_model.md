# TASK-004: Create `schedules` Model and Alembic Migration

> **Status:** `COMPLETED` | **Phase:** `Phase 1 — Foundation` | **Owner:** `@backend-agent`

## 1. Objective & Scope
Define the `Schedule` SQLAlchemy 2.0 model (`schedules` table), `ShiftType` enum (`LONG`, `NIGHT`, `OFF`), and `ScheduleSource` enum (`MANUAL`, `SWAP`, `SALE`, `ADMIN`) per Table 3 in `specs/database_schema.md`. Enforce RULE 3.5 database constraints.

## 2. Requirements & Specifications
### Table Specification (`schedules`)
| Column | Type | Attributes | Description |
|---|---|---|---|
| `id` | BigInteger | PK, Autoincrement | Internal primary key |
| `uuid` | String(36) | Unique, Not Null, Indexed | External public reference UUID |
| `user_id` | BigInteger | FK (`users.id`, `CASCADE`), Not Null | Assigned nurse |
| `date` | Date | Not Null, Indexed | Calendar date of shift assignment |
| `shift_type` | Enum(ShiftType) | Not Null | Shift type (`LONG`, `NIGHT`, `OFF`) |
| `source` | Enum(ScheduleSource) | Default: `MANUAL`, Not Null | Origin of shift assignment |
| `note` | String(255) | Nullable | Optional personal notes |
| `deleted_at` | DateTime | Nullable | Soft-delete timestamp (RULE 3.2) |
| `created_at` | DateTime | Default: `CURRENT_TIMESTAMP` | Creation timestamp |
| `updated_at` | DateTime | Default: `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Last update timestamp |

### Database Constraints (RULE 3.5)
- **Unique Constraint (`uq_schedules_user_date`)**: `UNIQUE(user_id, date)`. A nurse cannot have two active schedule entries for the exact same calendar date.
- **Indices**: `idx_schedules_date` on `date` and `idx_schedules_user_month` on `(user_id, date)` for rapid monthly range queries.

## 3. Acceptance Criteria
1. `Schedule` model defines composite `UniqueConstraint("user_id", "date", name="uq_schedules_user_date")`.
2. Alembic migration `fc79f9cea97f_create_schedules_table.py` creates table with foreign key to `users.id` (`ON DELETE CASCADE`).
3. Dual-database compatibility ensures `Date` columns accept Python `datetime.date` objects in SQLite unit tests.

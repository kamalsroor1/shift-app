# TASK-003: Create `users` Model and Alembic Migration

> **Status:** `COMPLETED` | **Phase:** `Phase 1 — Foundation` | **Owner:** `@backend-agent`

## 1. Objective & Scope
Define the `User` SQLAlchemy 2.0 model (`users` table) and `UserRole` enum (`nurse`, `partner`, `admin`) corresponding to Table 2 (`users`) in `specs/database_schema.md` along with its Alembic migration.

## 2. Requirements & Specifications
### Table Specification (`users`)
| Column | Type | Attributes | Description |
|---|---|---|---|
| `id` | BigInteger | PK, Autoincrement | Internal primary key (`BigInteger().with_variant(Integer, "sqlite")`) |
| `uuid` | String(36) | Unique, Not Null, Indexed | External public reference UUID |
| `department_id` | BigInteger | FK (`departments.id`, `RESTRICT`), Not Null | Belonging department |
| `full_name` | String(150) | Not Null | Nurse or user full legal name |
| `employee_id` | String(50) | Unique, Not Null | Hospital staff badge ID |
| `phone` | String(20) | Unique, Not Null | Primary contact / login phone |
| `email` | String(191) | Unique, Nullable | Optional email address |
| `password` | String(255) | Not Null | Hashed password (passlib/bcrypt) |
| `role` | Enum(UserRole) | Default: `NURSE`, Not Null | User role (`nurse`, `partner`, `admin`) |
| `fcm_token` | String(255) | Nullable | Firebase Cloud Messaging push token |
| `deleted_at` | DateTime | Nullable | Soft-delete timestamp (RULE 3.2) |
| `created_at` | DateTime | Default: `CURRENT_TIMESTAMP` | Creation timestamp |
| `updated_at` | DateTime | Default: `CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP` | Last update timestamp |

### Relationships
- `department`: Many-to-One with `Department`.
- `schedules`: One-to-Many with `Schedule`.
- `family_links_primary` & `family_links_partner`: One-to-Many with `FamilyLink`.
- `shift_swaps_requested` & `shift_swaps_received`: One-to-Many with `ShiftSwap`.
- `shift_sales_sold` & `shift_sales_bought`: One-to-Many with `ShiftSale`.
- `ledger_debits` & `ledger_credits`: One-to-Many with `FinancialLedger`.

## 3. Acceptance Criteria
1. `User` model strictly enforces unique indices on `uuid`, `phone`, `employee_id`, and `email`.
2. Foreign key to `departments.id` configured with `ondelete="RESTRICT"`.
3. Alembic migration `d9b0c5dbf5da_create_users_table.py` defines schema cleanly.

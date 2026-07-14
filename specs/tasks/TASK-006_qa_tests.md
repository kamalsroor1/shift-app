# TASK-006: Phase 1 QA Pytest Database Constraint & Model Tests

> **Status:** `COMPLETED` | **Phase:** `Phase 1 — Foundation` | **Owner:** `@qa-agent`

## 1. Objective & Scope
Create and execute a comprehensive unit testing suite using `pytest` to verify table definitions, unique constraints, and the double-entry ledger immutability event hook across all 7 SQLAlchemy models.

## 2. Requirements & Specifications
### Test File Location
- `backend/tests/__init__.py`
- `backend/tests/conftest.py` (Pytest async and engine fixtures)
- `backend/tests/unit/test_db_constraints.py`

### Required Test Cases
1. **`test_models_have_correct_tablenames`**:
   Verify `__tablename__` matches exactly for `Department`, `User`, `Schedule`, `FamilyLink`, `ShiftSwap`, `ShiftSale`, and `FinancialLedger`.
2. **`test_schedule_has_unique_user_date_constraint`**:
   Inspect `Schedule.__table__.constraints` and assert `uq_schedules_user_date` (`user_id`, `date`) exists.
3. **`test_departments_unique_constraints`**:
   Verify `Department` columns `uuid` and `code` have `unique=True`.
4. **`test_ledger_immutability_guard_event_listener`**:
   - Create an in-memory SQLite database (`sqlite:///:memory:`).
   - Insert dummy `Department`, `User`s, `Schedule`, `ShiftSale`, and a `FinancialLedger` entry with `status=LedgerStatus.SETTLED`.
   - Commit session and attempt to modify `ledger.amount = Decimal("100.00")`.
   - Assert `ImmutableRecordException` is raised with message `"Settled ledger records cannot be modified."`.

## 3. Acceptance Criteria
1. All tests run cleanly with zero failures (`pytest tests/unit/test_db_constraints.py -v` returns exit code 0).
2. All date and datetime inputs properly use Python `datetime.date` and `datetime.datetime` objects for strict SQLite/MySQL type compatibility.

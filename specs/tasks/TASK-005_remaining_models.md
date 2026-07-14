# TASK-005: Create Remaining Core Models (`family_links`, `shift_swaps`, `shift_sales`, `financial_ledger`) & Immutability Guard

> **Status:** `COMPLETED` | **Phase:** `Phase 1 — Foundation` | **Owner:** `@backend-agent`

## 1. Objective & Scope
Implement the 4 remaining core models corresponding to Tables 4, 5, 6, and 7 in `specs/database_schema.md` along with their Alembic migration and the critical double-entry ledger immutability event hook (RULE 3.4).

## 2. Requirements & Specifications
### Models & Enums to Implement
1. **`FamilyLink` (Table 4 — `family_links`)**:
   - Connects `primary_nurse_id` and `partner_user_id` (`uq_family_links_pair`).
   - Enum `FamilyLinkStatus`: `PENDING`, `ACTIVE`, `REVOKED`.
2. **`ShiftSwap` (Table 5 — `shift_swaps`)**:
   - Peer-to-peer shift swap requests between `requester_id` and `recipient_id`.
   - Enum `SwapStatus`: `PENDING`, `ACCEPTED`, `CONFIRMED`, `COMPLETED`, `REJECTED`, `CANCELLED`, `EXPIRED`.
3. **`ShiftSale` (Table 6 — `shift_sales`)**:
   - Marketplace listings where `seller_id` offers a shift (`schedule_id`) for an `asking_amount`.
   - Enum `SaleStatus`: `LISTED`, `PURCHASED`, `CONFIRMED`, `SETTLED`, `CANCELLED`, `EXPIRED`.
4. **`FinancialLedger` (Table 7 — `financial_ledger`)**:
   - Double-entry accounting records (`DEBIT` and `CREDIT` rows via `transaction_ref`).
   - Enum `EntryType`: `DEBIT`, `CREDIT`.
   - Enum `LedgerStatus`: `UNSETTLED`, `SETTLED`.

### Immutability Event Hook (RULE 3.4)
An event listener (`@event.listens_for(FinancialLedger, "before_update")`) MUST be registered on `FinancialLedger`.
When any update occurs on a `FinancialLedger` instance:
- Inspect attribute history using `sqlalchemy.orm.attributes.get_history(target, 'status')`.
- If the original/current status is `LedgerStatus.SETTLED` (`history.deleted[0] == SETTLED` or `history.unchanged[0] == SETTLED`), raise `ImmutableRecordException("Settled ledger records cannot be modified.")`.

## 3. Acceptance Criteria
1. All 4 models and their associated enums are exported in `app/models/__init__.py`.
2. Alembic migration `fa3d09a3a6fe_create_remaining_core_tables.py` creates all 4 tables with correct foreign keys and indices.
3. Attempting to modify a `SETTLED` ledger record triggers `ImmutableRecordException`.

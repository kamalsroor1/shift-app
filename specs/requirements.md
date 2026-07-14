# ShiftSync — Product & Functional Requirements
> **Status:** `DRAFT` | **Version:** `2.0.0` | **Last Updated:** 2026-07-14  
> **Owner:** Project Lead | **Reviewers:** Backend Agent (FastAPI), Frontend Agent (Flutter), QA Agent

---

## 1. Product Overview

ShiftSync is a specialized mobile application for hospital nursing departments. It solves three interlinked problems:

1. **Fragmented Scheduling**: Nurses currently track shifts manually on paper or in shared WhatsApp groups.
2. **Unmanaged Shift Trading**: Ad-hoc swaps and sales happen informally with no audit trail.
3. **Opaque Financial Debts**: When a shift is sold, the resulting money owed between nurses is tracked only in personal notes, leading to disputes.

ShiftSync replaces all three workflows with a structured, department-isolated digital system.

---

## 2. User Roles & Permissions

### 2.1 Role Matrix

| Capability | Nurse (Worker) | Partner (Spouse) | Dept. Admin |
|---|:---:|:---:|:---:|
| View own monthly schedule | YES | YES (read-only) | YES |
| Enter / edit own shifts | YES | NO | YES (override) |
| View department schedule | YES | NO | YES |
| Post shift for swap | YES | NO | NO |
| Accept a swap offer | YES | NO | NO |
| Post shift for sale | YES | NO | NO |
| Purchase a shift | YES | NO | NO |
| Mark debt as settled | YES (creditor only) | NO | NO |
| Manage department members | NO | NO | YES |
| View audit logs | NO | NO | YES |
| Receive push notifications | YES | YES | YES |

### 2.2 Role Definitions

#### Nurse (Worker)
The primary actor. A registered nurse belonging to exactly one department. Can perform all scheduling, swap, sale, and ledger actions within their department boundary.

#### Partner (Spouse / Family Member)
A linked non-nurse account. Can view the linked nurse's personal monthly schedule and receive push notifications when shifts change (e.g., an accepted swap that alters the schedule). Cannot interact with any transactional features.

#### Department Admin
A nurse with elevated privileges for their specific department. Manages the roster, can override schedule entries, and has read-only access to all swap and sale activity within the department. Cannot perform financial settlements on behalf of nurses.

---

## 3. Core Feature Specifications

### 3.1 Authentication & Onboarding

**FR-AUTH-01**: Registration requires: full name, employee ID, phone number (unique), password, and department selection.

**FR-AUTH-02**: Login via phone number + password using OAuth2 Password Bearer flow. Returns a JWT access token (`Bearer`) with a 30-day expiry (or access/refresh token pair).

**FR-AUTH-03**: A nurse can only belong to one department at a time. Department change requests must be approved by an admin.

**FR-AUTH-04**: Password reset via OTP sent to registered phone number (via SMS gateway or email fallback).

---

### 3.2 Single-Tap Calendar Entry

**FR-CAL-01**: The calendar screen displays a full month view. Each day cell is tappable.

**FR-CAL-02**: Tapping an empty day opens a shift-type picker. Tapping an assigned day cycles through types or opens an edit sheet.

**FR-CAL-03** — Shift Types (non-negotiable definitions):

| Shift Type | Code | Hours | Start | End |
|---|---|---|---|---|
| Long Day | `LONG` | 11h | 09:00 | 20:00 |
| Sahr / Night | `NIGHT` | 13h | 20:00 | 09:00 (+1d) |
| Day Off | `OFF` | 0h | — | — |

**FR-CAL-04**: Batch entry mode: nurse can drag across multiple days to assign the same shift type in one gesture.

**FR-CAL-05**: The system prevents saving a shift if a non-deleted schedule record already exists for that nurse on that date (enforce RULE 3.5 from constitution).

**FR-CAL-06**: A summary widget below the calendar shows:
- Total hours worked this month (sum of scheduled shift hours)
- Count of each shift type
- Remaining hours to complete a configurable monthly target (default: 160h)

---

### 3.3 Department Isolation

**FR-DEPT-01**: A nurse's department membership is set at registration and determines the scope of ALL marketplace and swap interactions.

**FR-DEPT-02**: API must enforce department scope at the database query level via FastAPI dependency injection (`Depends(get_current_active_user)` and department query filters), not just at the UI level. A nurse from Department A MUST NOT be able to call an API endpoint to see Department B's marketplace or swap board, even with a valid JWT.

**FR-DEPT-03**: Admins are scoped to their own department only. There is no super-admin role in v1.

---

### 3.4 Shift Swapping Engine

**FR-SWAP-01**: A nurse (Requester) can propose a swap by selecting one of their own shifts and targeting a specific colleague (Recipient) within the same department.

**FR-SWAP-02**: The swap proposal includes: Requester's shift date, Recipient's shift date (the date they want in return), and an optional message.

**FR-SWAP-03** — Swap State Machine:

```
PENDING --> ACCEPTED --> CONFIRMED (by both parties) --> COMPLETED
        --> REJECTED  (terminal)
        --> CANCELLED (by Requester, only while PENDING)
        --> EXPIRED   (system auto-cancels after 48h if no response)
```

**FR-SWAP-04**: The Recipient must explicitly accept. On acceptance, both parties see a "Confirm" step where they review the final swap. Both must confirm for the swap to complete.

**FR-SWAP-05**: On `COMPLETED`, the `schedules` table is updated atomically inside an async/sync SQLAlchemy database transaction (`session.begin()`): the two shift dates are swapped between the two nurses' records.

**FR-SWAP-06**: Real-time push (FastAPI WebSockets + FCM via Firebase Admin SDK) notifies the Recipient of a new swap proposal and notifies both parties on each state transition.

**FR-SWAP-07**: A nurse cannot have more than 3 active (PENDING or ACCEPTED) outgoing swap proposals at one time.

---

### 3.5 Shift Selling Marketplace

**FR-SALE-01**: A nurse (Seller) can list one of their scheduled shifts for sale. Listing includes: the shift date, the shift type, and an optional note.

**FR-SALE-02**: Only nurses in the same department can see and act on a listing.

**FR-SALE-03** — Sale State Machine:

```
LISTED --> PURCHASED (by a Buyer) --> CONFIRMED (admin or auto) --> SETTLED
        --> CANCELLED (by Seller, only while LISTED)
        --> EXPIRED   (system auto-cancels after 7 days if not purchased)
```

**FR-SALE-04**: A Buyer claims the listing. Upon claiming:
1. The `schedules` table is updated: the shift date is re-assigned to the Buyer.
2. The original Seller's record for that date is set to `OFF` (or deleted and replaced).
3. A `shift_sales` record is marked `PURCHASED`.
4. Two `financial_ledger` records are created (see § 3.6).

All of steps 1–4 MUST occur inside a single SQLAlchemy database transaction (RULE 3.1).

**FR-SALE-05**: A nurse cannot purchase their own listing.

**FR-SALE-06**: A nurse cannot list a shift that is already part of an active swap proposal.

**FR-SALE-07**: The marketplace shows all active (`LISTED`) shifts within the nurse's department, sorted by listing date (newest first).

---

### 3.6 Financial Ledger & Debt Tracking

**FR-LEDGER-01** — Double-Entry at Sale Completion:

When a sale is completed (state → `PURCHASED`):

| Ledger Record | `from_user_id` | `to_user_id` | `entry_type` | Meaning (Arabic) |
|---|---|---|---|---|
| Record A (Debit) | Seller | Buyer | `DEBIT` | Seller owes Buyer — عليا فلوس |
| Record B (Credit) | Buyer | Seller | `CREDIT` | Buyer is owed — ليا فلوس |

The two records are linked via a shared `transaction_ref` UUID.

**FR-LEDGER-02**: The `amount` field stores the pre-agreed or default shift compensation value (configurable per department by admin). In v1, the amount is set by the Seller at listing time and is informational (no actual payment processing).

**FR-LEDGER-03** — Settlement Rule:
- ONLY the `to_user_id` (the Buyer / creditor — the one who is owed — ليا فلوس) can trigger the "Mark as Settled" action.
- Settling one record automatically settles its linked pair (via `transaction_ref`).
- Settled records are **immutable**. The `settled_at` timestamp is set and the record cannot be modified.

**FR-LEDGER-04**: The Ledger Wallet screen shows two sections:
- **I OWE** (عليا فلوس): All unsettled DEBIT records where the current user is `from_user_id`. Shown in red.
- **OWED TO ME** (ليا فلوس): All unsettled CREDIT records where the current user is `to_user_id`. Shown in green. These cards have the "Confirm Settlement" action button.

**FR-LEDGER-05**: Historical settled transactions are accessible via a "History" tab on the Ledger screen, shown in a neutral/muted style.

---

### 4. Non-Functional Requirements

| ID | Requirement | Target |
|---|---|---|
| NFR-01 | API response time (p95) | < 200ms under normal load (via FastAPI async performance) |
| NFR-02 | App cold start time | < 2 seconds on a mid-range Android device |
| NFR-03 | Shift calendar render | < 100ms for month re-render |
| NFR-04 | Offline capability | Read-only for last-cached schedule; all writes require connectivity |
| NFR-05 | Data retention | Schedules and ledger records retained for 5 years minimum |
| NFR-06 | Concurrent swap safety | System must handle simultaneous swap acceptance without double-completion |

---

### 5. Out of Scope (v1)

- Payroll integration or actual monetary transfer
- Multi-hospital or multi-facility support
- Dark mode
- Web application
- Reporting / analytics dashboard for hospital management
- AI-based shift optimization suggestions

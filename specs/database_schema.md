# ShiftSync — Database Schema Specification
> **Status:** `DRAFT` | **Version:** `2.0.0` | **Last Updated:** 2026-07-14  
> **Engine:** MySQL 8.0+ | **ORM:** SQLAlchemy 2.0 (Declarative / Async) | **Migrations:** Alembic  
> **Migration Order:** Follow the chronological Alembic revision script order.

---

## Overview

```
users
 ├── belongs to ──> departments
 ├── has many  ──> schedules
 ├── has many  ──> family_links (as primary_nurse)
 ├── has many  ──> shift_swaps (as requester or recipient)
 ├── has many  ──> shift_sales (as seller or buyer)
 └── has many  ──> financial_ledger (as from_user or to_user)

departments
 └── has many  ──> users

shift_swaps
 ├── references users (requester_id)
 ├── references users (recipient_id)
 └── references schedules (requester_schedule_id, recipient_schedule_id)

shift_sales
 ├── references users (seller_id, buyer_id)
 └── references schedules (schedule_id)

financial_ledger
 ├── references users (from_user_id, to_user_id)
 └── references shift_sales (shift_sale_id)
```

---

## Table 1: `departments`

**Raw SQL Schema:**

```sql
CREATE TABLE departments (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    uuid          CHAR(36)        NOT NULL,
    name          VARCHAR(150)    NOT NULL,
    code          VARCHAR(20)     NOT NULL,   -- e.g. "ICU-A", "NICU-B"
    hospital_name VARCHAR(150)    NULL,
    monthly_target_hours SMALLINT UNSIGNED NOT NULL DEFAULT 160,
    created_at    TIMESTAMP       NULL,
    updated_at    TIMESTAMP       NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_departments_uuid (uuid),
    UNIQUE KEY uq_departments_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**SQLAlchemy 2.0 Model Specification (`app/models/department.py`):**
```python
from datetime import datetime
from typing import Optional, List
from sqlalchemy import String, SmallInteger, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

class Department(Base):
    __tablename__ = "departments"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    code: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    hospital_name: Mapped[Optional[str]] = mapped_column(String(150), nullable=True)
    monthly_target_hours: Mapped[int] = mapped_column(SmallInteger, default=160, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    users: Mapped[List["User"]] = relationship("User", back_populates="department")
```

---

## Table 2: `users`

**Raw SQL Schema:**

```sql
CREATE TABLE users (
    id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    uuid              CHAR(36)        NOT NULL,
    department_id     BIGINT UNSIGNED NOT NULL,
    full_name         VARCHAR(150)    NOT NULL,
    employee_id       VARCHAR(50)     NOT NULL,   -- Hospital-issued ID
    phone             VARCHAR(20)     NOT NULL,
    email             VARCHAR(191)    NULL,
    password          VARCHAR(255)    NOT NULL,
    role              ENUM('nurse','partner','admin') NOT NULL DEFAULT 'nurse',
    fcm_token         VARCHAR(255)    NULL,        -- Firebase Cloud Messaging
    deleted_at        TIMESTAMP       NULL,
    created_at        TIMESTAMP       NULL,
    updated_at        TIMESTAMP       NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_users_uuid       (uuid),
    UNIQUE KEY uq_users_phone      (phone),
    UNIQUE KEY uq_users_employee   (employee_id),
    KEY        idx_users_dept      (department_id),
    KEY        idx_users_role      (role),
    CONSTRAINT fk_users_dept FOREIGN KEY (department_id)
        REFERENCES departments(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**SQLAlchemy 2.0 Model (`app/models/user.py`):**
```python
from datetime import datetime
from typing import Optional, List
import enum
from sqlalchemy import String, ForeignKey, Enum, DateTime, func, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

class UserRole(str, enum.Enum):
    NURSE = "nurse"
    PARTNER = "partner"
    ADMIN = "admin"

class User(Base):
    __tablename__ = "users"
    __table_args__ = (
        Index("idx_users_dept", "department_id"),
        Index("idx_users_role", "role"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False)
    department_id: Mapped[int] = mapped_column(ForeignKey("departments.id", ondelete="RESTRICT"), nullable=False)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    employee_id: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    phone: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(191), unique=True, nullable=True)
    password: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), default=UserRole.NURSE, nullable=False)
    fcm_token: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    department: Mapped["Department"] = relationship("Department", back_populates="users")
    schedules: Mapped[List["Schedule"]] = relationship("Schedule", back_populates="user")
```

---

## Table 3: `schedules`

> Core table. Every row represents a single nurse's shift assignment for one date.
> The unique constraint on `(user_id, date)` enforces Rule 3.5 from the constitution.

```sql
CREATE TABLE schedules (
    id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    uuid        CHAR(36)        NOT NULL,
    user_id     BIGINT UNSIGNED NOT NULL,
    date        DATE            NOT NULL,
    shift_type  ENUM('LONG','NIGHT','OFF') NOT NULL,
    source      ENUM('MANUAL','SWAP','SALE','ADMIN') NOT NULL DEFAULT 'MANUAL',
    note        VARCHAR(255)    NULL,
    deleted_at  TIMESTAMP       NULL,
    created_at  TIMESTAMP       NULL,
    updated_at  TIMESTAMP       NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_schedules_uuid         (uuid),
    UNIQUE KEY uq_schedules_user_date    (user_id, date),
    KEY        idx_schedules_date        (date),
    KEY        idx_schedules_user_month  (user_id, date),
    CONSTRAINT fk_schedules_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**SQLAlchemy 2.0 Model (`app/models/schedule.py`):**
```python
from datetime import datetime, date
from typing import Optional
import enum
from sqlalchemy import String, ForeignKey, Enum, Date, DateTime, func, UniqueConstraint, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

class ShiftType(str, enum.Enum):
    LONG = "LONG"
    NIGHT = "NIGHT"
    OFF = "OFF"

class ScheduleSource(str, enum.Enum):
    MANUAL = "MANUAL"
    SWAP = "SWAP"
    SALE = "SALE"
    ADMIN = "ADMIN"

class Schedule(Base):
    __tablename__ = "schedules"
    __table_args__ = (
        UniqueConstraint("user_id", "date", name="uq_schedules_user_date"),
        Index("idx_schedules_date", "date"),
        Index("idx_schedules_user_month", "user_id", "date"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    date: Mapped[date] = mapped_column(Date, nullable=False)
    shift_type: Mapped[ShiftType] = mapped_column(Enum(ShiftType), nullable=False)
    source: Mapped[ScheduleSource] = mapped_column(Enum(ScheduleSource), default=ScheduleSource.MANUAL)
    note: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    user: Mapped["User"] = relationship("User", back_populates="schedules")
```

---

## Table 4: `family_links`

> Links a Nurse account to one or more Partner (spouse/family) accounts.

```sql
CREATE TABLE family_links (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    primary_nurse_id BIGINT UNSIGNED NOT NULL,
    partner_user_id  BIGINT UNSIGNED NOT NULL,
    status           ENUM('PENDING','ACTIVE','REVOKED') NOT NULL DEFAULT 'PENDING',
    linked_at        TIMESTAMP       NULL,
    created_at       TIMESTAMP       NULL,
    updated_at       TIMESTAMP       NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_family_links_pair (primary_nurse_id, partner_user_id),
    KEY idx_family_partner           (partner_user_id),
    CONSTRAINT fk_fl_nurse   FOREIGN KEY (primary_nurse_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_fl_partner FOREIGN KEY (partner_user_id)  REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Table 5: `shift_swaps`

```sql
CREATE TABLE shift_swaps (
    id                       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    uuid                     CHAR(36)        NOT NULL,
    department_id            BIGINT UNSIGNED NOT NULL,
    requester_id             BIGINT UNSIGNED NOT NULL,
    recipient_id             BIGINT UNSIGNED NOT NULL,
    requester_schedule_id    BIGINT UNSIGNED NOT NULL,
    recipient_schedule_id    BIGINT UNSIGNED NOT NULL,
    status                   ENUM('PENDING','ACCEPTED','CONFIRMED','COMPLETED','REJECTED','CANCELLED','EXPIRED') NOT NULL DEFAULT 'PENDING',
    requester_confirmed_at   TIMESTAMP       NULL,
    recipient_confirmed_at   TIMESTAMP       NULL,
    message                  VARCHAR(500)    NULL,
    expires_at               TIMESTAMP       NOT NULL,
    completed_at             TIMESTAMP       NULL,
    deleted_at               TIMESTAMP       NULL,
    created_at               TIMESTAMP       NULL,
    updated_at               TIMESTAMP       NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_shift_swaps_uuid          (uuid),
    KEY        idx_swap_department          (department_id),
    KEY        idx_swap_requester           (requester_id),
    KEY        idx_swap_recipient           (recipient_id),
    KEY        idx_swap_status              (status),
    KEY        idx_swap_dept_status         (department_id, status),
    CONSTRAINT fk_swap_dept      FOREIGN KEY (department_id)         REFERENCES departments(id),
    CONSTRAINT fk_swap_req       FOREIGN KEY (requester_id)          REFERENCES users(id),
    CONSTRAINT fk_swap_rec       FOREIGN KEY (recipient_id)          REFERENCES users(id),
    CONSTRAINT fk_swap_req_sched FOREIGN KEY (requester_schedule_id) REFERENCES schedules(id),
    CONSTRAINT fk_swap_rec_sched FOREIGN KEY (recipient_schedule_id) REFERENCES schedules(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Table 6: `shift_sales`

```sql
CREATE TABLE shift_sales (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    uuid          CHAR(36)        NOT NULL,
    department_id BIGINT UNSIGNED NOT NULL,
    seller_id     BIGINT UNSIGNED NOT NULL,
    buyer_id      BIGINT UNSIGNED NULL,
    schedule_id   BIGINT UNSIGNED NOT NULL,
    asking_amount DECIMAL(10, 2)  NOT NULL DEFAULT 0.00,
    status        ENUM('LISTED','PURCHASED','CONFIRMED','SETTLED','CANCELLED','EXPIRED') NOT NULL DEFAULT 'LISTED',
    seller_note   VARCHAR(500)    NULL,
    purchased_at  TIMESTAMP       NULL,
    settled_at    TIMESTAMP       NULL,
    expires_at    TIMESTAMP       NOT NULL,
    deleted_at    TIMESTAMP       NULL,
    created_at    TIMESTAMP       NULL,
    updated_at    TIMESTAMP       NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_shift_sales_uuid         (uuid),
    UNIQUE KEY uq_shift_sales_schedule     (schedule_id),
    KEY        idx_sale_department         (department_id),
    KEY        idx_sale_seller             (seller_id),
    KEY        idx_sale_buyer              (buyer_id),
    KEY        idx_sale_status             (status),
    KEY        idx_sale_dept_status        (department_id, status),
    CONSTRAINT fk_sale_dept     FOREIGN KEY (department_id) REFERENCES departments(id),
    CONSTRAINT fk_sale_seller   FOREIGN KEY (seller_id)     REFERENCES users(id),
    CONSTRAINT fk_sale_buyer    FOREIGN KEY (buyer_id)      REFERENCES users(id),
    CONSTRAINT fk_sale_schedule FOREIGN KEY (schedule_id)   REFERENCES schedules(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Table 7: `financial_ledger`

> Implements double-entry bookkeeping. Every sale event creates exactly two rows
> linked by `transaction_ref`. Records are append-only — never updated post-settlement.

```sql
CREATE TABLE financial_ledger (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    uuid             CHAR(36)        NOT NULL,
    transaction_ref  CHAR(36)        NOT NULL,
    shift_sale_id    BIGINT UNSIGNED NOT NULL,
    from_user_id     BIGINT UNSIGNED NOT NULL,
    to_user_id       BIGINT UNSIGNED NOT NULL,
    entry_type       ENUM('DEBIT','CREDIT')  NOT NULL,
    amount           DECIMAL(10, 2)           NOT NULL,
    currency         CHAR(3)         NOT NULL DEFAULT 'IQD',
    status           ENUM('UNSETTLED','SETTLED') NOT NULL DEFAULT 'UNSETTLED',
    settled_at       TIMESTAMP       NULL,
    settled_by       BIGINT UNSIGNED NULL,
    note             VARCHAR(255)    NULL,
    deleted_at       TIMESTAMP       NULL,
    created_at       TIMESTAMP       NULL,
    updated_at       TIMESTAMP       NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_ledger_uuid            (uuid),
    KEY        idx_ledger_transaction    (transaction_ref),
    KEY        idx_ledger_from_user      (from_user_id),
    KEY        idx_ledger_to_user        (to_user_id),
    KEY        idx_ledger_status         (status),
    KEY        idx_ledger_sale           (shift_sale_id),
    KEY        idx_ledger_from_status    (from_user_id, status),
    KEY        idx_ledger_to_status      (to_user_id, status),
    CONSTRAINT fk_ledger_sale       FOREIGN KEY (shift_sale_id) REFERENCES shift_sales(id),
    CONSTRAINT fk_ledger_from       FOREIGN KEY (from_user_id)  REFERENCES users(id),
    CONSTRAINT fk_ledger_to         FOREIGN KEY (to_user_id)    REFERENCES users(id),
    CONSTRAINT fk_ledger_settled_by FOREIGN KEY (settled_by)    REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**SQLAlchemy 2.0 Immutability Guard (`app/models/financial_ledger.py`):**
```python
from sqlalchemy import event
from sqlalchemy.orm import object_session
from app.exceptions import ImmutableRecordException

# SQLAlchemy event listener enforcing RULE 3.4
@event.listens_for(FinancialLedger, "before_update")
def receive_before_update(mapper, connection, target):
    session = object_session(target)
    if target.status == LedgerStatus.SETTLED and session.is_modified(target, include_collections=False):
        # Allow only setting status to settled for the first time
        # Check original state in database or session state
        history = target.status.history
        if history.has_changes() and history.deleted[0] == LedgerStatus.SETTLED:
            raise ImmutableRecordException("Settled ledger records cannot be modified.")
```

---

## Index Strategy Summary

| Query Pattern | Index Used |
|---|---|
| Get nurse's monthly schedule | `idx_schedules_user_month` on `(user_id, date)` |
| Get dept marketplace listings | `idx_sale_dept_status` on `(department_id, status)` |
| Get dept active swaps | `idx_swap_dept_status` on `(department_id, status)` |
| Get nurse's wallet debts | `idx_ledger_from_status` on `(from_user_id, status)` |
| Get nurse's wallet claims | `idx_ledger_to_status` on `(to_user_id, status)` |
| Resolve linked ledger pair | `idx_ledger_transaction` on `transaction_ref` |

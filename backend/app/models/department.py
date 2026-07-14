from datetime import datetime
from typing import Optional, List, TYPE_CHECKING
from sqlalchemy import String, SmallInteger, DateTime, func, BigInteger, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base

if TYPE_CHECKING:
    from app.models.user import User

class Department(Base):
    """Department model representing a hospital nursing department (Table 1)."""
    __tablename__ = "departments"

    id: Mapped[int] = mapped_column(BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True)
    uuid: Mapped[str] = mapped_column(String(36), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    code: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)
    hospital_name: Mapped[Optional[str]] = mapped_column(String(150), nullable=True)
    monthly_target_hours: Mapped[int] = mapped_column(SmallInteger, default=160, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now(), onupdate=func.now())

    users: Mapped[List["User"]] = relationship("User", back_populates="department")

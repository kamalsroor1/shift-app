import uuid
from typing import Optional
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.models.user import User
from app.models.department import Department
from app.schemas.auth import UserRegisterRequest
from app.core.security import get_password_hash, verify_password

class AuthService:
    """Service layer encapsulating registration, authentication, and user verification logic."""

    async def register_user(self, db: AsyncSession, register_data: UserRegisterRequest) -> User:
        # 1. Lookup department by code
        dept_stmt = select(Department).where(Department.code == register_data.department_code)
        department = await db.scalar(dept_stmt)
        if not department:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Department with code '{register_data.department_code}' not found"
            )

        # 2. Check existing user constraints (phone, employee_id, email)
        if register_data.email:
            check_stmt = select(User).where(
                (User.phone == register_data.phone) |
                (User.employee_id == register_data.employee_id) |
                (User.email == register_data.email)
            )
        else:
            check_stmt = select(User).where(
                (User.phone == register_data.phone) |
                (User.employee_id == register_data.employee_id)
            )
        existing_user = await db.scalar(check_stmt)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="User with this phone, employee ID, or email already exists"
            )

        # 3. Create new user
        user_uuid = str(uuid.uuid4())
        hashed_pw = get_password_hash(register_data.password)
        new_user = User(
            uuid=user_uuid,
            department_id=department.id,
            full_name=register_data.full_name,
            employee_id=register_data.employee_id,
            phone=register_data.phone,
            email=register_data.email,
            password=hashed_pw,
            role=register_data.role,
            fcm_token=register_data.fcm_token
        )
        db.add(new_user)
        await db.commit()

        # 4. Fetch created user with eager department load
        fetch_stmt = select(User).options(selectinload(User.department)).where(User.id == new_user.id)
        return await db.scalar(fetch_stmt)

    async def authenticate_user(self, db: AsyncSession, phone_or_emp_id: str, password: str) -> User:
        stmt = select(User).options(selectinload(User.department)).where(
            (User.phone == phone_or_emp_id) | (User.employee_id == phone_or_emp_id)
        )
        user = await db.scalar(stmt)
        if not user or user.deleted_at is not None or not verify_password(password, user.password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return user

auth_service = AuthService()

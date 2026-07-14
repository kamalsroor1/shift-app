import uuid
from typing import Optional, Sequence
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.department import Department
from app.schemas.department import DepartmentCreateRequest, DepartmentUpdateRequest

class DepartmentService:
    """Service layer encapsulating department query and CRUD logic."""

    async def list_departments(self, db: AsyncSession, search: Optional[str] = None) -> Sequence[Department]:
        stmt = select(Department).order_by(Department.name)
        if search:
            stmt = stmt.where(
                Department.name.ilike(f"%{search}%") | Department.code.ilike(f"%{search}%")
            )
        result = await db.scalars(stmt)
        return result.all()

    async def get_department_by_uuid(self, db: AsyncSession, dept_uuid: str) -> Department:
        stmt = select(Department).where(Department.uuid == dept_uuid)
        department = await db.scalar(stmt)
        if not department:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Department not found"
            )
        return department

    async def create_department(self, db: AsyncSession, create_data: DepartmentCreateRequest) -> Department:
        check_stmt = select(Department).where(Department.code == create_data.code)
        existing = await db.scalar(check_stmt)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Department with this code already exists"
            )

        new_uuid = str(uuid.uuid4())
        department = Department(
            uuid=new_uuid,
            name=create_data.name,
            code=create_data.code,
            hospital_name=create_data.hospital_name,
            monthly_target_hours=create_data.monthly_target_hours
        )
        db.add(department)
        await db.commit()
        await db.refresh(department)
        return department

    async def update_department(self, db: AsyncSession, dept_uuid: str, update_data: DepartmentUpdateRequest) -> Department:
        department = await self.get_department_by_uuid(db, dept_uuid)

        if update_data.code is not None and update_data.code != department.code:
            check_stmt = select(Department).where(Department.code == update_data.code)
            existing = await db.scalar(check_stmt)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Department with this code already exists"
                )
            department.code = update_data.code

        if update_data.name is not None:
            department.name = update_data.name
        if update_data.hospital_name is not None:
            department.hospital_name = update_data.hospital_name
        if update_data.monthly_target_hours is not None:
            department.monthly_target_hours = update_data.monthly_target_hours

        await db.commit()
        await db.refresh(department)
        return department

department_service = DepartmentService()

from typing import Optional, List
from fastapi import APIRouter, Depends, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.schemas.department import DepartmentResponse, DepartmentCreateRequest, DepartmentUpdateRequest
from app.services.department_service import department_service
from app.api.deps import get_current_active_user, verify_department_admin
from app.models.user import User

router = APIRouter()

@router.get("", response_model=List[DepartmentResponse])
async def list_departments(
    search: Optional[str] = Query(None, description="Optional search term for department name or code"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
) -> List[DepartmentResponse]:
    """List all departments (accessible by any authenticated user)."""
    departments = await department_service.list_departments(db, search=search)
    return [DepartmentResponse.model_validate(d) for d in departments]

@router.get("/{uuid}", response_model=DepartmentResponse)
async def get_department(
    uuid: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
) -> DepartmentResponse:
    """Get department details by UUID."""
    department = await department_service.get_department_by_uuid(db, uuid)
    return DepartmentResponse.model_validate(department)

@router.post("", response_model=DepartmentResponse, status_code=status.HTTP_201_CREATED)
async def create_department(
    create_data: DepartmentCreateRequest,
    db: AsyncSession = Depends(get_db),
    admin_user: User = Depends(verify_department_admin)
) -> DepartmentResponse:
    """Create a new department (Admin only)."""
    department = await department_service.create_department(db, create_data)
    return DepartmentResponse.model_validate(department)

@router.patch("/{uuid}", response_model=DepartmentResponse)
async def update_department(
    uuid: str,
    update_data: DepartmentUpdateRequest,
    db: AsyncSession = Depends(get_db),
    admin_user: User = Depends(verify_department_admin)
) -> DepartmentResponse:
    """Update department attributes (Admin only)."""
    department = await department_service.update_department(db, uuid, update_data)
    return DepartmentResponse.model_validate(department)

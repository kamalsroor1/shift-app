from fastapi import APIRouter, Depends, status, Request, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.schemas.auth import UserRegisterRequest, TokenResponse, UserResponse
from app.services.auth_service import auth_service
from app.core.security import create_access_token
from app.api.deps import get_current_active_user
from app.models.user import User

router = APIRouter()

async def get_login_credentials(request: Request) -> tuple[str, str]:
    content_type = request.headers.get("content-type", "").lower()
    if "application/json" in content_type:
        try:
            body = await request.json()
        except Exception:
            body = {}
        phone_or_emp_id = body.get("phone_or_employee_id") or body.get("username")
        password = body.get("password")
    else:
        try:
            form = await request.form()
            phone_or_emp_id = form.get("username") or form.get("phone_or_employee_id")
            password = form.get("password")
        except Exception:
            phone_or_emp_id = None
            password = None

    if not phone_or_emp_id or not password:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Missing username/phone_or_employee_id or password"
        )
    return phone_or_emp_id, password

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    register_data: UserRegisterRequest,
    db: AsyncSession = Depends(get_db)
) -> TokenResponse:
    """Register a new user and return JWT access token along with user profile."""
    user = await auth_service.register_user(db, register_data)
    access_token = create_access_token(subject=user.uuid)
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse.model_validate(user)
    )

@router.post("/login", response_model=TokenResponse)
async def login(
    credentials: tuple[str, str] = Depends(get_login_credentials),
    db: AsyncSession = Depends(get_db)
) -> TokenResponse:
    """Authenticate a user using form-data or JSON and return JWT access token."""
    phone_or_emp_id, password = credentials
    user = await auth_service.authenticate_user(db, phone_or_emp_id, password)
    access_token = create_access_token(subject=user.uuid)
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse.model_validate(user)
    )

@router.post("/refresh", response_model=TokenResponse)
async def refresh(
    current_user: User = Depends(get_current_active_user)
) -> TokenResponse:
    """Refresh JWT access token for current active user."""
    access_token = create_access_token(subject=current_user.uuid)
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse.model_validate(current_user)
    )

@router.get("/me", response_model=UserResponse)
async def get_me(
    current_user: User = Depends(get_current_active_user)
) -> UserResponse:
    """Get current active user profile."""
    return UserResponse.model_validate(current_user)

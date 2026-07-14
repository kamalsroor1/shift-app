from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.router import api_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Ensure essential default data (Departments, Admin user) is seeded when server starts."""
    try:
        from app.db.session import async_session_maker
        from app.models.department import Department
        from app.models.user import User, UserRole
        from app.core.security import get_password_hash
        from sqlalchemy import select

        async with async_session_maker() as db:
            depts_data = [
                {"name": "Emergency Department", "code": "EMERGENCY", "target": 180},
                {"name": "Intensive Care Unit", "code": "ICU", "target": 160},
                {"name": "Pediatrics Department", "code": "PEDIATRIC", "target": 150},
                {"name": "Surgery Department", "code": "SURGERY", "target": 168},
            ]
            first_dept = None
            for d in depts_data:
                stmt = select(Department).where(Department.code == d["code"])
                existing = await db.scalar(stmt)
                if not existing:
                    dept = Department(
                        uuid=f"dept-{d['code'].lower()}",
                        name=d["name"],
                        code=d["code"],
                        monthly_target_hours=d["target"]
                    )
                    db.add(dept)
                    if not first_dept:
                        first_dept = dept
                elif not first_dept:
                    first_dept = existing
            await db.commit()

            admin_phone = "07800000000"
            stmt_admin = select(User).where(User.phone == admin_phone)
            existing_admin = await db.scalar(stmt_admin)
            if not existing_admin and first_dept:
                hashed = get_password_hash("AdminSecret123!")
                admin_user = User(
                    uuid="user-super-admin-01",
                    department_id=first_dept.id,
                    full_name="System Super Admin",
                    employee_id="ADM-001",
                    phone=admin_phone,
                    password=hashed,
                    role=UserRole.ADMIN
                )
                db.add(admin_user)
                await db.commit()
    except Exception as e:
        # Ignore seeding error if database table is not yet migrated
        pass
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    version="0.1.0",
    lifespan=lifespan,
)

# Set all CORS enabled origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint confirming API status."""
    return {
        "status": 200,
        "message": "ShiftSync FastAPI service is healthy and running.",
        "data": {"version": "0.1.0"},
        "meta": {}
    }

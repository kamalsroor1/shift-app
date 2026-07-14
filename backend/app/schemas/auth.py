from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, ConfigDict, Field, model_validator
from app.models.user import UserRole

class UserRegisterRequest(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=150)
    employee_id: str = Field(..., min_length=2, max_length=50)
    phone: str = Field(..., min_length=6, max_length=20)
    email: Optional[str] = Field(None, max_length=191)
    password: str = Field(..., min_length=6, max_length=128)
    department_code: str = Field(..., min_length=2, max_length=20)
    role: UserRole = UserRole.NURSE
    fcm_token: Optional[str] = Field(None, max_length=255)

class UserLoginRequest(BaseModel):
    phone_or_employee_id: str = Field(...)
    password: str = Field(...)

class UserResponse(BaseModel):
    uuid: str
    full_name: str
    employee_id: str
    phone: str
    email: Optional[str] = None
    role: UserRole
    department_uuid: str
    department_code: str
    fcm_token: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="before")
    @classmethod
    def extract_department_fields(cls, data: Any) -> Any:
        if hasattr(data, "department") and data.department:
            dept = data.department
            if not isinstance(data, dict):
                return {
                    "uuid": getattr(data, "uuid"),
                    "full_name": getattr(data, "full_name"),
                    "employee_id": getattr(data, "employee_id"),
                    "phone": getattr(data, "phone"),
                    "email": getattr(data, "email"),
                    "role": getattr(data, "role"),
                    "department_uuid": getattr(dept, "uuid"),
                    "department_code": getattr(dept, "code"),
                    "fcm_token": getattr(data, "fcm_token"),
                    "created_at": getattr(data, "created_at"),
                }
            elif isinstance(data, dict) and "department" in data and data["department"]:
                dept_obj = data["department"]
                data["department_uuid"] = getattr(dept_obj, "uuid", None) or (dept_obj.get("uuid") if isinstance(dept_obj, dict) else None)
                data["department_code"] = getattr(dept_obj, "code", None) or (dept_obj.get("code") if isinstance(dept_obj, dict) else None)
        return data

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

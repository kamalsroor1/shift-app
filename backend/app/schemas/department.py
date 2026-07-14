from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field

class DepartmentCreateRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=150)
    code: str = Field(..., min_length=2, max_length=20)
    hospital_name: Optional[str] = Field(None, max_length=150)
    monthly_target_hours: int = Field(160, ge=0, le=744)

class DepartmentUpdateRequest(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=150)
    code: Optional[str] = Field(None, min_length=2, max_length=20)
    hospital_name: Optional[str] = Field(None, max_length=150)
    monthly_target_hours: Optional[int] = Field(None, ge=0, le=744)

class DepartmentResponse(BaseModel):
    uuid: str
    name: str
    code: str
    hospital_name: Optional[str] = None
    monthly_target_hours: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

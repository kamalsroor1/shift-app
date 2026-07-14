from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator

class FamilyLinkCreateRequest(BaseModel):
    partner_phone: Optional[str] = Field(None, description="Phone number of partner user to link")
    partner_user_uuid: Optional[str] = Field(None, description="UUID of partner user to link")

    @model_validator(mode="after")
    def validate_identifier(self) -> "FamilyLinkCreateRequest":
        if not self.partner_phone and not self.partner_user_uuid:
            raise ValueError("Either partner_phone or partner_user_uuid must be provided.")
        return self

class FamilyLinkResponse(BaseModel):
    uuid: str
    primary_nurse_uuid: str
    partner_user_uuid: str
    primary_nurse_name: str
    partner_name: str
    status: str
    linked_at: Optional[datetime] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="before")
    @classmethod
    def extract_relationship_fields(cls, data: Any) -> Any:
        if hasattr(data, "primary_nurse") and data.primary_nurse:
            data.primary_nurse_uuid = data.primary_nurse.uuid
            data.primary_nurse_name = data.primary_nurse.full_name
        if hasattr(data, "partner_user") and data.partner_user:
            data.partner_user_uuid = data.partner_user.uuid
            data.partner_name = data.partner_user.full_name
        return data

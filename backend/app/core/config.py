from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "ShiftSync API"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "change-me-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30  # 30 days default

    DATABASE_URL: str = "mysql+aiomysql://root:@localhost:3306/shiftsync_db"
    SYNC_DATABASE_URL: str = "mysql+pymysql://root:@localhost:3306/shiftsync_db"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

settings = Settings()

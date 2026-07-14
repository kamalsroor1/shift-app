import pytest
import pytest_asyncio
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from app.models.base import Base

@pytest.fixture(scope="session")
def anyio_backend():
    return "asyncio"

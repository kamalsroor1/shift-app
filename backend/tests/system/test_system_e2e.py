import os
import pytest
import shutil
from alembic.config import Config
from alembic import command
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.department import Department

DB_FILE = "test_system_migration.db"
DATABASE_URL = f"sqlite:///{DB_FILE}"

@pytest.fixture(scope="module")
def run_migrations_e2e():
    # Remove any existing test db
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)

    # Initialize Alembic config
    # We run from the backend directory context
    alembic_cfg = Config("alembic.ini")
    alembic_cfg.set_main_option("sqlalchemy.url", DATABASE_URL)

    # Upgrade to head
    command.upgrade(alembic_cfg, "head")
    
    yield DATABASE_URL

    # Downgrade to base
    command.downgrade(alembic_cfg, "base")

    # Clean up test file
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)

def test_full_migration_lifecycle_and_seeding(run_migrations_e2e):
    """Verify programmatic migration upgrade/downgrade cycle & test data insertion."""
    engine = create_engine(run_migrations_e2e)
    Session = sessionmaker(bind=engine)
    session = Session()

    # Verify tables exist by inserting test record
    dept = Department(uuid="system-dept-1", name="System Testing", code="SYS-T")
    session.add(dept)
    session.commit()

    # Query back
    result = session.query(Department).filter_by(code="SYS-T").first()
    assert result is not None
    assert result.name == "System Testing"

    session.close()
    engine.dispose()

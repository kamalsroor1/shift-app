#!/usr/bin/env python3
"""
ShiftSync Artisan CLI (`manage.py`)
===================================
A powerful command-line interface designed to give a Laravel Artisan-like development experience
for the ShiftSync FastAPI & SQLAlchemy backend project.

Usage:
    python manage.py --help
    python manage.py test
    python manage.py migrate
    python manage.py make:migration "create orders table"
    python manage.py db:seed
    python manage.py serve
"""

import os
import sys
import subprocess
import asyncio
from typing import Optional

# Auto-detect and re-launch inside virtual environment if running with global Python outside venv
BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
VENV_PYTHON = os.path.join(BACKEND_DIR, "venv", "Scripts", "python.exe")
if not sys.prefix.endswith("venv") and os.path.exists(VENV_PYTHON) and os.path.abspath(sys.executable) != os.path.abspath(VENV_PYTHON):
    # Re-launch current script using the virtual environment's python.exe
    result = subprocess.run([VENV_PYTHON, __file__] + sys.argv[1:])
    sys.exit(result.returncode)

# Force UTF-8 encoding for Windows terminals to prevent UnicodeEncodeError with emojis/symbols
if sys.platform.startswith("win"):
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    os.environ["PYTHONIOENCODING"] = "utf-8"

try:
    import typer
    from rich.console import Console
    from rich.panel import Panel
    from rich import print as rprint
except ModuleNotFoundError:
    print("❌ Error: Required modules (typer, rich) not found. Please activate your venv (.\\venv\\Scripts\\activate) or run pip install -e .[dev]")
    sys.exit(1)

app = typer.Typer(
    name="shiftsync",
    help="ShiftSync Artisan CLI - Manage migrations, tests, seeding, and scaffolding.",
    add_completion=False,
)
console = Console()

# Ensure we are inside the backend directory
BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(BACKEND_DIR)
if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)


@app.command("serve")
def serve(
    host: str = typer.Option("127.0.0.1", "--host", "-h", help="Host address to bind to"),
    port: int = typer.Option(8000, "--port", "-p", help="Port to listen on"),
    reload: bool = typer.Option(True, "--reload/--no-reload", help="Enable auto-reload on code changes"),
):
    """Run the FastAPI development server using Uvicorn."""
    console.print(
        Panel.fit(
            f"[bold green]Starting ShiftSync API Server[/bold green]\n"
            f"[bold cyan]URL:[/bold cyan] http://{host}:{port}\n"
            f"[bold cyan]Docs:[/bold cyan] http://{host}:{port}/docs",
            title="ShiftSync CLI",
            border_style="green",
        )
    )
    cmd = [sys.executable, "-m", "uvicorn", "app.main:app", f"--host={host}", f"--port={port}"]
    if reload:
        cmd.append("--reload")
    subprocess.run(cmd)


@app.command("test")
def run_tests(
    path: str = typer.Argument("tests", help="Path to test directory or specific test file"),
    verbose: bool = typer.Option(True, "-v", "--verbose", help="Run tests in verbose mode"),
    coverage: bool = typer.Option(False, "--cov", "-c", help="Run with pytest-cov report if installed"),
):
    """Run automated unit & integration tests using Pytest."""
    console.print(f"[bold yellow][TEST][/bold yellow] Running Pytest suites on: [cyan]{path}[/cyan]")
    cmd = [sys.executable, "-m", "pytest", path]
    if verbose:
        cmd.append("-v")
    if coverage:
        cmd.extend(["--cov=app", "--cov-report=term-missing"])
    result = subprocess.run(cmd)
    if result.returncode == 0:
        console.print("[bold green][SUCCESS] All test suites passed successfully![/bold green]")
    else:
        console.print("[bold red][ERROR] Some tests failed. Please review output above.[/bold red]")


@app.command("migrate")
def migrate(
    revision: str = typer.Argument("head", help="Target revision (default: head for latest migration)"),
):
    """Run pending database migrations using Alembic (alembic upgrade head)."""
    console.print(f"[bold blue][MIGRATE][/bold blue] Upgrading database schema to: [cyan]{revision}[/cyan]")
    subprocess.run([sys.executable, "-m", "alembic", "upgrade", revision])
    console.print("[bold green][SUCCESS] Database schema upgrade complete![/bold green]")


@app.command("rollback")
def rollback(
    steps: int = typer.Option(1, "--steps", "-n", help="Number of steps to downgrade"),
):
    """Rollback the latest database migration (alembic downgrade -n)."""
    target = f"-{steps}"
    console.print(f"[bold yellow][ROLLBACK][/bold yellow] Rolling back database schema by: [cyan]{steps} steps ({target})[/cyan]")
    subprocess.run([sys.executable, "-m", "alembic", "downgrade", target])
    console.print("[bold green][SUCCESS] Rollback complete![/bold green]")


@app.command("make:migration")
def make_migration(
    message: str = typer.Argument(..., help="Descriptive name for the migration revision"),
    autogenerate: bool = typer.Option(True, "--auto/--empty", help="Auto-detect schema changes from models"),
):
    """Generate a new Alembic migration script from SQLAlchemy model changes."""
    console.print(f"[bold purple][SCAFFOLD][/bold purple] Creating migration: [cyan]{message}[/cyan]")
    cmd = [sys.executable, "-m", "alembic", "revision", "-m", message]
    if autogenerate:
        cmd.append("--autogenerate")
    subprocess.run(cmd)
    console.print("[bold green][SUCCESS] Migration file generated successfully inside alembic/versions/[/bold green]")


@app.command("db:seed")
def seed_database():
    """Seed the database with initial required data (Admin user, Default Departments)."""
    console.print("[bold green][SEED][/bold green] Seeding initial data into database...")
    
    async def _seed_async():
        from app.db.session import async_session_maker
        from app.models.department import Department
        from app.models.user import User, UserRole
        from app.core.security import get_password_hash
        from sqlalchemy import select

        async with async_session_maker() as db:
            # 1. Ensure core departments exist
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
                    console.print(f"  + Created department: [cyan]{d['name']} ({d['code']})[/cyan]")
                    if not first_dept:
                        first_dept = dept
                else:
                    if not first_dept:
                        first_dept = existing

            await db.commit()

            # 2. Ensure default admin user exists
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
                console.print(f"  + Created default Admin User -> Phone: [bold yellow]{admin_phone}[/bold yellow], Password: [bold yellow]AdminSecret123![/bold yellow]")
            else:
                console.print(f"  * Admin user ({admin_phone}) already exists.")

    asyncio.run(_seed_async())
    console.print("[bold green][SUCCESS] Database seeding complete![/bold green]")


@app.command("make:service")
def make_service(
    name: str = typer.Argument(..., help="Name of the service (e.g., OrderService or order)"),
):
    """Scaffold a new Service class inside app/services/."""
    clean_name = name.replace("Service", "").lower()
    class_name = f"{clean_name.capitalize()}Service"
    filename = f"app/services/{clean_name}_service.py"

    if os.path.exists(filename):
        console.print(f"[bold red][ERROR] File {filename} already exists![/bold red]")
        raise typer.Exit(code=1)

    content = f'''from typing import Optional, Sequence
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

class {class_name}:
    """Service layer encapsulating business logic and database interactions for {clean_name}."""

    def __init__(self):
        pass

{clean_name}_service = {class_name}()
'''
    with open(filename, "w", encoding="utf-8") as f:
        f.write(content)
    console.print(f"[bold green][SUCCESS] Scaffolded service:[/bold green] [cyan]{filename}[/cyan] with class [bold]{class_name}[/bold]")


@app.command("make:schema")
def make_schema(
    name: str = typer.Argument(..., help="Name of the domain schema (e.g., order or OrderDTO)"),
):
    """Scaffold a new Pydantic DTO schema inside app/schemas/."""
    clean_name = name.lower().replace("dto", "").replace("schema", "")
    class_prefix = clean_name.capitalize()
    filename = f"app/schemas/{clean_name}.py"

    if os.path.exists(filename):
        console.print(f"[bold red][ERROR] File {filename} already exists![/bold red]")
        raise typer.Exit(code=1)

    content = f'''from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field

class {class_prefix}CreateRequest(BaseModel):
    name: str = Field(..., description="Name or title")

class {class_prefix}UpdateRequest(BaseModel):
    name: Optional[str] = None

class {class_prefix}Response(BaseModel):
    uuid: str
    name: str
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
'''
    with open(filename, "w", encoding="utf-8") as f:
        f.write(content)
    console.print(f"[bold green][SUCCESS] Scaffolded DTO schema:[/bold green] [cyan]{filename}[/cyan]")


if __name__ == "__main__":
    app()

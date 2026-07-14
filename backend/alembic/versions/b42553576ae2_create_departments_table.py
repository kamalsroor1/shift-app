"""create departments table

Revision ID: b42553576ae2
Revises: 
Create Date: 2026-07-14 20:52:28.877780

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b42553576ae2'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    is_mysql = op.get_bind().dialect.name == 'mysql'
    updated_at_default = sa.text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP') if is_mysql else sa.text('CURRENT_TIMESTAMP')

    op.create_table(
        'departments',
        sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
        sa.Column('uuid', sa.String(length=36), nullable=False),
        sa.Column('name', sa.String(length=150), nullable=False),
        sa.Column('code', sa.String(length=20), nullable=False),
        sa.Column('hospital_name', sa.String(length=150), nullable=True),
        sa.Column('monthly_target_hours', sa.SmallInteger(), server_default='160', nullable=False),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=True),
        sa.Column('updated_at', sa.DateTime(), server_default=updated_at_default, nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('uuid', name='uq_departments_uuid'),
        sa.UniqueConstraint('code', name='uq_departments_code')
    )
    op.create_index(op.f('ix_departments_uuid'), 'departments', ['uuid'], unique=True)


def downgrade() -> None:
    op.drop_index(op.f('ix_departments_uuid'), table_name='departments')
    op.drop_table('departments')

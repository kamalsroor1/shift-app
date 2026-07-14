"""create users table

Revision ID: d9b0c5dbf5da
Revises: b42553576ae2
Create Date: 2026-07-14 20:53:04.311025

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'd9b0c5dbf5da'
down_revision: Union[str, None] = 'b42553576ae2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    is_mysql = op.get_bind().dialect.name == 'mysql'
    updated_at_default = sa.text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP') if is_mysql else sa.text('CURRENT_TIMESTAMP')

    op.create_table(
        'users',
        sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
        sa.Column('uuid', sa.String(length=36), nullable=False),
        sa.Column('department_id', sa.BigInteger(), nullable=False),
        sa.Column('full_name', sa.String(length=150), nullable=False),
        sa.Column('employee_id', sa.String(length=50), nullable=False),
        sa.Column('phone', sa.String(length=20), nullable=False),
        sa.Column('email', sa.String(length=191), nullable=True),
        sa.Column('password', sa.String(length=255), nullable=False),
        sa.Column('role', sa.Enum('nurse', 'partner', 'admin', name='userrole'), server_default='nurse', nullable=False),
        sa.Column('fcm_token', sa.String(length=255), nullable=True),
        sa.Column('deleted_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=True),
        sa.Column('updated_at', sa.DateTime(), server_default=updated_at_default, nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('uuid', name='uq_users_uuid'),
        sa.UniqueConstraint('phone', name='uq_users_phone'),
        sa.UniqueConstraint('employee_id', name='uq_users_employee'),
        sa.UniqueConstraint('email', name='uq_users_email'),
        sa.ForeignKeyConstraint(['department_id'], ['departments.id'], name='fk_users_dept', ondelete='RESTRICT', onupdate='CASCADE')
    )
    op.create_index('idx_users_dept', 'users', ['department_id'])
    op.create_index('idx_users_role', 'users', ['role'])


def downgrade() -> None:
    op.drop_index('idx_users_role', table_name='users')
    op.drop_index('idx_users_dept', table_name='users')
    op.drop_table('users')

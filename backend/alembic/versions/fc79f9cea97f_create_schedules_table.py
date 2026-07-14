"""create schedules table

Revision ID: fc79f9cea97f
Revises: d9b0c5dbf5da
Create Date: 2026-07-14 20:53:36.289725

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'fc79f9cea97f'
down_revision: Union[str, None] = 'd9b0c5dbf5da'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    is_mysql = op.get_bind().dialect.name == 'mysql'
    updated_at_default = sa.text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP') if is_mysql else sa.text('CURRENT_TIMESTAMP')

    op.create_table(
        'schedules',
        sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
        sa.Column('uuid', sa.String(length=36), nullable=False),
        sa.Column('user_id', sa.BigInteger(), nullable=False),
        sa.Column('date', sa.Date(), nullable=False),
        sa.Column('shift_type', sa.Enum('LONG', 'NIGHT', 'OFF', name='shifttype'), nullable=False),
        sa.Column('source', sa.Enum('MANUAL', 'SWAP', 'SALE', 'ADMIN', name='schedulesource'), server_default='MANUAL', nullable=False),
        sa.Column('note', sa.String(length=255), nullable=True),
        sa.Column('deleted_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=True),
        sa.Column('updated_at', sa.DateTime(), server_default=updated_at_default, nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('uuid', name='uq_schedules_uuid'),
        sa.UniqueConstraint('user_id', 'date', name='uq_schedules_user_date'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], name='fk_schedules_user', ondelete='CASCADE', onupdate='CASCADE')
    )
    op.create_index('idx_schedules_date', 'schedules', ['date'])
    op.create_index('idx_schedules_user_month', 'schedules', ['user_id', 'date'])


def downgrade() -> None:
    op.drop_index('idx_schedules_user_month', table_name='schedules')
    op.drop_index('idx_schedules_date', table_name='schedules')
    op.drop_table('schedules')

"""add uuid column to family_links

Revision ID: 54dde23e1a50
Revises: fa3d09a3a6fe
Create Date: 2026-07-14 21:31:56.989824

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

# revision identifiers, used by Alembic.
revision: str = '54dde23e1a50'
down_revision: Union[str, None] = 'fa3d09a3a6fe'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('family_links', sa.Column('uuid', sa.String(length=36), nullable=False))
    op.create_index('idx_family_links_uuid', 'family_links', ['uuid'], unique=True)


def downgrade() -> None:
    op.drop_index('idx_family_links_uuid', table_name='family_links')
    op.drop_column('family_links', 'uuid')

"""create remaining core tables

Revision ID: fa3d09a3a6fe
Revises: fc79f9cea97f
Create Date: 2026-07-14 20:54:23.858706

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'fa3d09a3a6fe'
down_revision: Union[str, None] = 'fc79f9cea97f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    is_mysql = op.get_bind().dialect.name == 'mysql'
    updated_at_default = sa.text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP') if is_mysql else sa.text('CURRENT_TIMESTAMP')

    # Table 4: family_links
    op.create_table(
        'family_links',
        sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
        sa.Column('primary_nurse_id', sa.BigInteger(), nullable=False),
        sa.Column('partner_user_id', sa.BigInteger(), nullable=False),
        sa.Column('status', sa.Enum('PENDING', 'ACTIVE', 'REVOKED', name='familylinkstatus'), server_default='PENDING', nullable=False),
        sa.Column('linked_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=True),
        sa.Column('updated_at', sa.DateTime(), server_default=updated_at_default, nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('primary_nurse_id', 'partner_user_id', name='uq_family_links_pair'),
        sa.ForeignKeyConstraint(['primary_nurse_id'], ['users.id'], name='fk_fl_nurse', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['partner_user_id'], ['users.id'], name='fk_fl_partner', ondelete='CASCADE')
    )
    op.create_index('idx_family_partner', 'family_links', ['partner_user_id'])

    # Table 5: shift_swaps
    op.create_table(
        'shift_swaps',
        sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
        sa.Column('uuid', sa.String(length=36), nullable=False),
        sa.Column('department_id', sa.BigInteger(), nullable=False),
        sa.Column('requester_id', sa.BigInteger(), nullable=False),
        sa.Column('recipient_id', sa.BigInteger(), nullable=False),
        sa.Column('requester_schedule_id', sa.BigInteger(), nullable=False),
        sa.Column('recipient_schedule_id', sa.BigInteger(), nullable=False),
        sa.Column('status', sa.Enum('PENDING', 'ACCEPTED', 'CONFIRMED', 'COMPLETED', 'REJECTED', 'CANCELLED', 'EXPIRED', name='swapstatus'), server_default='PENDING', nullable=False),
        sa.Column('requester_confirmed_at', sa.DateTime(), nullable=True),
        sa.Column('recipient_confirmed_at', sa.DateTime(), nullable=True),
        sa.Column('message', sa.String(length=500), nullable=True),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('completed_at', sa.DateTime(), nullable=True),
        sa.Column('deleted_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=True),
        sa.Column('updated_at', sa.DateTime(), server_default=updated_at_default, nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('uuid', name='uq_shift_swaps_uuid'),
        sa.ForeignKeyConstraint(['department_id'], ['departments.id'], name='fk_swap_dept'),
        sa.ForeignKeyConstraint(['requester_id'], ['users.id'], name='fk_swap_req'),
        sa.ForeignKeyConstraint(['recipient_id'], ['users.id'], name='fk_swap_rec'),
        sa.ForeignKeyConstraint(['requester_schedule_id'], ['schedules.id'], name='fk_swap_req_sched'),
        sa.ForeignKeyConstraint(['recipient_schedule_id'], ['schedules.id'], name='fk_swap_rec_sched')
    )
    op.create_index('idx_swap_department', 'shift_swaps', ['department_id'])
    op.create_index('idx_swap_requester', 'shift_swaps', ['requester_id'])
    op.create_index('idx_swap_recipient', 'shift_swaps', ['recipient_id'])
    op.create_index('idx_swap_status', 'shift_swaps', ['status'])
    op.create_index('idx_swap_dept_status', 'shift_swaps', ['department_id', 'status'])

    # Table 6: shift_sales
    op.create_table(
        'shift_sales',
        sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
        sa.Column('uuid', sa.String(length=36), nullable=False),
        sa.Column('department_id', sa.BigInteger(), nullable=False),
        sa.Column('seller_id', sa.BigInteger(), nullable=False),
        sa.Column('buyer_id', sa.BigInteger(), nullable=True),
        sa.Column('schedule_id', sa.BigInteger(), nullable=False),
        sa.Column('asking_amount', sa.Numeric(precision=10, scale=2), server_default='0.00', nullable=False),
        sa.Column('status', sa.Enum('LISTED', 'PURCHASED', 'CONFIRMED', 'SETTLED', 'CANCELLED', 'EXPIRED', name='salestatus'), server_default='LISTED', nullable=False),
        sa.Column('seller_note', sa.String(length=500), nullable=True),
        sa.Column('purchased_at', sa.DateTime(), nullable=True),
        sa.Column('settled_at', sa.DateTime(), nullable=True),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('deleted_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=True),
        sa.Column('updated_at', sa.DateTime(), server_default=updated_at_default, nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('uuid', name='uq_shift_sales_uuid'),
        sa.UniqueConstraint('schedule_id', name='uq_shift_sales_schedule'),
        sa.ForeignKeyConstraint(['department_id'], ['departments.id'], name='fk_sale_dept'),
        sa.ForeignKeyConstraint(['seller_id'], ['users.id'], name='fk_sale_seller'),
        sa.ForeignKeyConstraint(['buyer_id'], ['users.id'], name='fk_sale_buyer'),
        sa.ForeignKeyConstraint(['schedule_id'], ['schedules.id'], name='fk_sale_schedule')
    )
    op.create_index('idx_sale_department', 'shift_sales', ['department_id'])
    op.create_index('idx_sale_seller', 'shift_sales', ['seller_id'])
    op.create_index('idx_sale_buyer', 'shift_sales', ['buyer_id'])
    op.create_index('idx_sale_status', 'shift_sales', ['status'])
    op.create_index('idx_sale_dept_status', 'shift_sales', ['department_id', 'status'])

    # Table 7: financial_ledger
    op.create_table(
        'financial_ledger',
        sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
        sa.Column('uuid', sa.String(length=36), nullable=False),
        sa.Column('transaction_ref', sa.String(length=36), nullable=False),
        sa.Column('shift_sale_id', sa.BigInteger(), nullable=False),
        sa.Column('from_user_id', sa.BigInteger(), nullable=False),
        sa.Column('to_user_id', sa.BigInteger(), nullable=False),
        sa.Column('entry_type', sa.Enum('DEBIT', 'CREDIT', name='entrytype'), nullable=False),
        sa.Column('amount', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('currency', sa.String(length=3), server_default='IQD', nullable=False),
        sa.Column('status', sa.Enum('UNSETTLED', 'SETTLED', name='ledgerstatus'), server_default='UNSETTLED', nullable=False),
        sa.Column('settled_at', sa.DateTime(), nullable=True),
        sa.Column('settled_by', sa.BigInteger(), nullable=True),
        sa.Column('note', sa.String(length=255), nullable=True),
        sa.Column('deleted_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=True),
        sa.Column('updated_at', sa.DateTime(), server_default=updated_at_default, nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('uuid', name='uq_ledger_uuid'),
        sa.ForeignKeyConstraint(['shift_sale_id'], ['shift_sales.id'], name='fk_ledger_sale'),
        sa.ForeignKeyConstraint(['from_user_id'], ['users.id'], name='fk_ledger_from'),
        sa.ForeignKeyConstraint(['to_user_id'], ['users.id'], name='fk_ledger_to'),
        sa.ForeignKeyConstraint(['settled_by'], ['users.id'], name='fk_ledger_settled_by')
    )
    op.create_index('idx_ledger_transaction', 'financial_ledger', ['transaction_ref'])
    op.create_index('idx_ledger_from_user', 'financial_ledger', ['from_user_id'])
    op.create_index('idx_ledger_to_user', 'financial_ledger', ['to_user_id'])
    op.create_index('idx_ledger_status', 'financial_ledger', ['status'])
    op.create_index('idx_ledger_sale', 'financial_ledger', ['shift_sale_id'])
    op.create_index('idx_ledger_from_status', 'financial_ledger', ['from_user_id', 'status'])
    op.create_index('idx_ledger_to_status', 'financial_ledger', ['to_user_id', 'status'])


def downgrade() -> None:
    op.drop_index('idx_ledger_to_status', table_name='financial_ledger')
    op.drop_index('idx_ledger_from_status', table_name='financial_ledger')
    op.drop_index('idx_ledger_sale', table_name='financial_ledger')
    op.drop_index('idx_ledger_status', table_name='financial_ledger')
    op.drop_index('idx_ledger_to_user', table_name='financial_ledger')
    op.drop_index('idx_ledger_from_user', table_name='financial_ledger')
    op.drop_index('idx_ledger_transaction', table_name='financial_ledger')
    op.drop_table('financial_ledger')

    op.drop_index('idx_sale_dept_status', table_name='shift_sales')
    op.drop_index('idx_sale_status', table_name='shift_sales')
    op.drop_index('idx_sale_buyer', table_name='shift_sales')
    op.drop_index('idx_sale_seller', table_name='shift_sales')
    op.drop_index('idx_sale_department', table_name='shift_sales')
    op.drop_table('shift_sales')

    op.drop_index('idx_swap_dept_status', table_name='shift_swaps')
    op.drop_index('idx_swap_status', table_name='shift_swaps')
    op.drop_index('idx_swap_recipient', table_name='shift_swaps')
    op.drop_index('idx_swap_requester', table_name='shift_swaps')
    op.drop_index('idx_swap_department', table_name='shift_swaps')
    op.drop_table('shift_swaps')

    op.drop_index('idx_family_partner', table_name='family_links')
    op.drop_table('family_links')

class RemoveStatusAndPreviousBalanceFromPaidLeaveBalances < ActiveRecord::Migration[8.1]
  def change
    remove_reference :paid_leave_balances, :previous_balance, foreign_key: { to_table: :paid_leave_balances }
    remove_column :paid_leave_balances, :status, :integer
  end
end

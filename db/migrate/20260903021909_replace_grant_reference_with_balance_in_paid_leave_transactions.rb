class ReplaceGrantReferenceWithBalanceInPaidLeaveTransactions < ActiveRecord::Migration[8.1]
  def change
    remove_reference :paid_leave_transactions, :paid_leave_grant, null: false, foreign_key: true
    add_reference :paid_leave_transactions, :paid_leave_balance, null: false, foreign_key: true
  end
end

class MakeDeltaDaysNotNullInPaidLeaveTransactions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :paid_leave_transactions, :delta_days, false
  end
end

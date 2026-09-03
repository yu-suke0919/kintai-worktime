class AddDeltaDaysToPaidLeaveTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :paid_leave_transactions, :delta_days, :integer
  end
end

class RemoveMinutesPerDayFromPaidLeaveBalances < ActiveRecord::Migration[8.1]
  def change
    remove_column :paid_leave_balances, :minutes_per_day, :integer
  end
end

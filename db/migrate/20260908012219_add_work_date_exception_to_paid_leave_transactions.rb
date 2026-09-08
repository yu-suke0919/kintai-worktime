class AddWorkDateExceptionToPaidLeaveTransactions < ActiveRecord::Migration[8.1]
  def change
    add_reference :paid_leave_transactions, :work_date_exception, null: false, foreign_key: true
  end
end

class CreatePaidLeaveBalances < ActiveRecord::Migration[8.1]
  def change
    create_table :paid_leave_balances do |t|
      t.references :paid_leave_grant, null: false, foreign_key: true
      t.references :previous_balance, foreign_key: { to_table: :paid_leave_balances }
      t.integer :minutes_per_day, null: false
      t.integer :status, null: false
      t.date :effective_from, null: false

      t.timestamps
    end
  end
end

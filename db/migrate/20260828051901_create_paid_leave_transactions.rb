class CreatePaidLeaveTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :paid_leave_transactions do |t|
      t.references :paid_leave_grant, null: false, foreign_key: true
      t.integer :delta_minutes, null: false
      t.integer :transaction_type, null: false
      t.text :reason, limit: 30, null: false
      t.date :effective_on, null: false

      t.timestamps
    end
  end
end

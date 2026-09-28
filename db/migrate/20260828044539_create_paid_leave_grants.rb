class CreatePaidLeaveGrants < ActiveRecord::Migration[8.1]
  def change
    create_table :paid_leave_grants do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :granted_by, foreign_key: { to_table: :employees }

      t.integer :granted_minutes, null: false
      t.date :granted_on, null: false
      t.date :expires_on, null: false

      t.timestamps
    end
  end
end

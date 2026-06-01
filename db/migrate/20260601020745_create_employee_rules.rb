class CreateEmployeeRules < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_rules do |t|
      t.references :employee, null: false, foreign_key: true
      t.integer :required_workdays_mask, null: false, default: 0
      t.time :core_time_start
      t.time :core_time_end
      t.integer :break_minutes, null: false, default: 0
      t.date :effective_from, null: false
      t.date :expires_on, null: false

      t.timestamps
    end
  end
end

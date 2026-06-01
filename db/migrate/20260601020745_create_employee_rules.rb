class CreateEmployeeRules < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_rules do |t|
      t.references :employee, null: false, foreign_key: true
      t.integer :required_workdays_mask
      t.time :core_time_start
      t.time :core_time_end
      t.integer :break_minutes
      t.date :effective_from
      t.date :expires_on

      t.timestamps
    end
  end
end

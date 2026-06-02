class AddScheduledWorkMinutesToEmployeeRules < ActiveRecord::Migration[8.1]
  def change
    add_column :employee_rules, :scheduled_work_minutes, :integer, null: false, default: 480
  end
end

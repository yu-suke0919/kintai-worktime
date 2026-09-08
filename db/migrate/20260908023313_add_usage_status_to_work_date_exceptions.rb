class AddUsageStatusToWorkDateExceptions < ActiveRecord::Migration[8.1]
  def change
    add_column :work_date_exceptions, :usage_status, :integer, null: false
  end
end

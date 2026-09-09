class AddHourlyLeaveFieldsToWorkDateExceptionRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :work_date_exception_requests, :starts_at, :datetime
    add_column :work_date_exception_requests, :ends_at, :datetime
    add_column :work_date_exception_requests, :leave_unit, :integer

    change_column_null :work_date_exception_requests, :start_date, true
    change_column_null :work_date_exception_requests, :end_date, true
  end
end

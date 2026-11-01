class RenameWorkDateExceptionRequestsToWorkScheduleChangeCases < ActiveRecord::Migration[8.1]
  def change
    rename_table :work_date_exception_requests, :work_schedule_change_cases
    rename_column :work_date_exceptions, :work_date_exception_request_id, :work_schedule_change_case_id
  end
end

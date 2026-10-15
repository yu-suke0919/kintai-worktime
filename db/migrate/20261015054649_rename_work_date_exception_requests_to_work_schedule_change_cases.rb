class RenameWorkDateExceptionRequestsToWorkScheduleChangeCases < ActiveRecord::Migration[8.1]
  def change
    rename_table :work_date_exception_requests, :work_schedule_change_cases
  end
end

class RenameEmployeeWorkDateExceptionRequests < ActiveRecord::Migration[8.1]
  def change
    rename_table :employee_work_date_exception_requests, :work_date_exception_requests
  end
end

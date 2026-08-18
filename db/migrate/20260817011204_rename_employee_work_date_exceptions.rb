class RenameEmployeeWorkDateExceptions < ActiveRecord::Migration[8.1]
  def change
    rename_table :employee_work_date_exceptions, :work_date_exceptions
  end
end

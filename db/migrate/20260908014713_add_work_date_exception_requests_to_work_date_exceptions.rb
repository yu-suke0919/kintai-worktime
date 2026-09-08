class AddWorkDateExceptionRequestsToWorkDateExceptions < ActiveRecord::Migration[8.1]
  def change
    add_reference :work_date_exceptions, :work_date_exception_request, null: false, foreign_key: true
  end
end

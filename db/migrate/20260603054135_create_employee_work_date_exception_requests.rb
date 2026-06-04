class CreateEmployeeWorkDateExceptionRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_work_date_exception_requests do |t|
      t.references :employee, null: false, foreign_key: true
      t.datetime :approved_at
      t.integer :approved_by_id
      t.integer :status, null: false, default: 0
      t.integer :request_type, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.text :reason

      t.timestamps
    end
  end
end

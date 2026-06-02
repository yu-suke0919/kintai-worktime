class CreateEmployeeWorkDateExceptions < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_work_date_exceptions do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :work_date, null: false
      t.integer :exception_type, null: false

      t.timestamps
    end
  end
end

class CreateMonthlyAttendanceClosings < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_attendance_closings do |t|
      t.references :employee,
                    null: false,
                    foreign_key: true
      t.date :target_month, null: false
      t.index [ :target_month, :employee_id ], unique: true

      t.timestamps
    end
  end
end

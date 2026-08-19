class CreateMonthlyAttendanceClosingApprovals < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_attendance_closing_approvals do |t|
      t.timestamps
    end
  end
end

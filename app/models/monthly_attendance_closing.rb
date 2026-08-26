class MonthlyAttendanceClosing < ApplicationRecord
  belongs_to :employee
  has_many :monthly_attendance_closing_approvals
end

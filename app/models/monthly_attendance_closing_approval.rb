class MonthlyAttendanceClosingApproval < ApplicationRecord
  enum :status, { pending: 0, approved: 1, rejected: 2 }
  belongs_to :monthly_attendance_closing
end

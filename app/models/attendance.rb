class Attendance < ApplicationRecord
  enum :status, {
  not_clocked: 0,
  working: 1,
  normal: 2,
  abnormal: 3,
  absent: 4,
  paid_leave: 5,
  holiday: 6,
  corrected: 20
}

  belongs_to :employee
  has_one :attendance_edit_request
end

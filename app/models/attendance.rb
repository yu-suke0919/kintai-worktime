class Attendance < ApplicationRecord
  belongs_to :employee
  has_one :attendance_edit_request
end

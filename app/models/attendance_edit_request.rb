class AttendanceEditRequest < ApplicationRecord
  belongs_to :attendance
  belongs_to :employee
end

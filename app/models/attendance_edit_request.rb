class AttendanceEditRequest < ApplicationRecord
  enum :edit_type, { work_time: 0, break_time: 1 }


  belongs_to :attendance
  belongs_to :employee
end

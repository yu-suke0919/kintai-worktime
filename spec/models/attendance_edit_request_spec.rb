require 'rails_helper'

RSpec.describe AttendanceEditRequest, type: :model do
  it "employeeに所属しているかどうか" do
    is_expected.to belong_to(:employee)
  end
  it "attendanceに所属しているかどうか" do
    is_expected.to belong_to(:attendance)
  end
end

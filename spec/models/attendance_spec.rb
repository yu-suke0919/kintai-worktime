require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let(:employee_1) { FactoryBot.create(:employee) }
  let(:attendance) { FactoryBot.create(:attendance, employee: employee_1) }
  it "employeeに所属しているかどうか" do
    is_expected.to belong_to(:employee)
  end
  it "attendance_edit_requestを1つ持つことができるかどうか" do
    is_expected.to have_one(:attendance_edit_request)
  end
end

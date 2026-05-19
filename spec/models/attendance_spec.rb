require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let(:employee_1) { FactoryBot.create(:employee) }
  let(:attendance) { FactoryBot.create(:attendance, employee: employee_1) }
  it "あああ" do
    expect(attendance).to belong_to(:employee)
  end
end

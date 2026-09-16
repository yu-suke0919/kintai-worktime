require 'rails_helper'

RSpec.describe PaidLeaves::BalanceCalculator, type: :service do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_rule) { FactoryBot.create(:employee_rule, employee: user_1) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@gmail.com", role: :manager) }
  let(:exception_request) { FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: :paid_leave) }
  let(:exception) { FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request, exception_type: :paid_leave) }
  let(:grant) { FactoryBot.build(:paid_leave_grant, employee: user_1, granted_by: user_manager) }
  # let(:balance) { FactoryBot.build(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule, effective_from: Date.new(2026, 4, 1)) }
  # let(:transaction) { FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance, delta_days: 1, work_date_exception: exception) }
end

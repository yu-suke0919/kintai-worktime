require 'rails_helper'

RSpec.describe PaidLeaveTransaction, type: :model do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_rule) { FactoryBot.create(:employee_rule, employee: user_1) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@gmail.com", role: :manager) }
  let(:grant) { FactoryBot.build(:paid_leave_grant, employee: user_1, granted_by: user_manager) }
  let(:balance) { FactoryBot.build(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule, effective_from: Date.new(2026, 4, 1)) }
  let(:exception_request) { FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: :paid_leave) }
  let(:exception) { FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request, exception_type: :paid_leave) }
  subject(:transaction) { FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance, delta_days: 1, work_date_exception: exception) }

  describe "validations" do
    context "すべての属性が適切な場合" do
      it "有効である" do
        is_expected.to be_valid
      end
    end
    context "paid_leave_balanceが指定されていない時" do
      before { transaction.paid_leave_balance = nil }
      it "無効である" do
        is_expected.to be_invalid
        expect(transaction.errors[:paid_leave_balance]).to be_present
      end
    end
    context "work_date_exceptionが指定されていない時" do
      before { transaction.work_date_exception = nil }
      it "無効である" do
        is_expected.to be_invalid
        expect(transaction.errors[:work_date_exception]).to be_present
      end
    end
  end
end

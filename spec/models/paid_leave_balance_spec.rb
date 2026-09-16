require 'rails_helper'

RSpec.describe PaidLeaveBalance, type: :model do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_rule) { FactoryBot.create(:employee_rule, employee: user_1) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@gmail.com", role: :manager) }
  let(:grant) { FactoryBot.build(:paid_leave_grant, employee: user_1, granted_by: user_manager) }
  subject(:balance) { FactoryBot.build(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule, effective_from: Date.new(2026, 4, 1)) }

  describe "validations" do
    context "すべての属性が適切な場合" do
      it "有効である" do
        is_expected.to be_valid
      end
    end
    context "employee_ruleが指定されていない時" do
      before { balance.employee_rule = nil }
      it "無効である" do
        is_expected.to be_invalid
        expect(balance.errors[:employee_rule]).to be_present
      end
    end
    context "paid_leave_grantが指定されていない時" do
      before { balance.paid_leave_grant = nil }
      it "無効である" do
        is_expected.to be_invalid
        expect(balance.errors[:paid_leave_grant]).to be_present
      end
    end
  end


  describe "balanceが持つtransactions" do
    let!(:tr1) { FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance, delta_days: 1, effective_on: Date.new(2026, 5, 1), work_date_exception: exception, transaction_type: :use) }
    let(:exception_request) { FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: :paid_leave) }
    let(:exception) { FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request, exception_type: :paid_leave) }

    context "transactionが1つ" do
      it "トランザクションが1つ生成" do
        expect(balance.transactions.count).to eq(1)
      end
    end
    context "transactionが2つ" do
      let!(:tr2) { FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance, delta_days: 1, effective_on: Date.new(2026, 5, 2), work_date_exception: exception, transaction_type: :use) }
      context "どちらも期限内のtransaction" do
        it "トランザクションが2個生成される" do
          expect(grant.balances.count).to eq(2)
        end
      end
    end
  end

  describe "effective_from変更不可な振る舞い" do
    before { balance.save! }
    it "effective_fromは変更できない" do
      balance.effective_from = Date.new(2024, 03, 30)
      expect(balance).to be_invalid
      expect(balance.errors[:effective_from]).to be_present
      expect(balance.reload.effective_from).to eq(Date.new(2026, 4, 1))
    end
  end
end

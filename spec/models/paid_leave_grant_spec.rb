require 'rails_helper'

RSpec.describe PaidLeaveGrant, type: :model do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@gmail.com", role: :manager) }
  subject(:grant) { FactoryBot.build(:paid_leave_grant, employee: user_1, granted_by: user_manager) }

  describe "validations" do
    context "すべての属性が適切な場合" do
      it "有効である" do
        is_expected.to be_valid
      end
    end
    context "employeeが指定されていない時" do
      before { grant.employee = nil }
      it "無効である" do
        is_expected.to be_invalid
      end
    end
    context "granted_byが指定されていない時" do
      before { grant.granted_by = nil }
      it "無効である" do
        is_expected.to be_invalid
      end
    end
  end
  describe "grant付与時のbalance作成" do
    let!(:user_1_rule) { FactoryBot.create(:employee_rule, employee: user_1) }
    before { grant.save! }
    context "grant有効期間内ルールが1つ" do
      it "残高が1つ生成" do
        expect(grant.balances.count).to eq(1)
      end
    end
    context "grant有効期間内ルールが2つ" do
      let!(:user_1_rule2) { FactoryBot.create(:employee_rule, employee: user_1, effective_from: Date.new(2027, 4, 1), expires_on: Date.new(2028, 3, 31)) }
      context "両方のルールは期間内開始" do
        it "残高が2つ生成され、どちらもruleの開始期間と同一" do
          expect(grant.balances.count).to eq(2)
        end
      end
      context "1つ目のルールはgrant期間前に開始済" do
        before do
          user_1_rule.effective_from = Date.new(2025, 4, 1)
        end
        it "残高が2つ生成され、期限前開始のRuleはgrantの期間開始時と同一になる。" do
          expect(grant.balances.count).to eq(2)
          expect(grant.balances[0].effective_from).to eq(Date.new(2026, 4, 1))
        end

        it "balanceの並び順は早い順になる" do
          expect(grant.balances[0].effective_from).to eq(Date.new(2026, 4, 1))
          expect(grant.balances[1].effective_from).to eq(Date.new(2027, 4, 1))
        end
      end
    end
  end
end

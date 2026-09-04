require 'rails_helper'

RSpec.describe PaidLeaveBalances::Synchronizer, type: :service do
  describe "for_new_paid_leave_grant!" do
    let(:employee) { FactoryBot.create(:employee) }
    let(:grant) { FactoryBot.create(:paid_leave_grant, employee:, granted_by: employee) }

    context "1つのgrant,1つのrule,それぞれ2026/04/01開始の場合" do
      let!(:rule_20260401) { FactoryBot.create(:employee_rule, employee:, effective_from: grant.granted_on, expires_on: grant.expires_on) }

      it "2026/04/01開始のBalanceが生成される" do
        described_class.for_new_paid_leave_grant!(grant)
        expect(PaidLeaveBalance.all.count).to eq 1
        expect(PaidLeaveBalance.exists?(effective_from: "2026-04-01")).to be true
      end
    end
    context "1つのgrant,1つのrule,26年8月開始のruleに対して26年4月開始のgrantが作られた場合" do
      let!(:rule_20250801) { FactoryBot.create(:employee_rule, employee:, effective_from: "2026-08-01", expires_on: "2027-03-31") }

      it "2026/08/01開始のBalanceが生成される" do
        described_class.for_new_paid_leave_grant!(grant)
        expect(PaidLeaveBalance.all.count).to eq 1
        expect(PaidLeaveBalance.exists?(effective_from: "2026-08-01")).to be true
      end
    end

    context "1つのgrant,1つのrule,25年開始のruleに対して26年開始のgrantが作られた場合" do
      let!(:rule_20250401) { FactoryBot.create(:employee_rule, employee:, effective_from: "2025-04-01", expires_on: "2027-03-31") }

      it "2026/04/01開始のBalanceが生成される" do
        described_class.for_new_paid_leave_grant!(grant)
        expect(PaidLeaveBalance.all.count).to eq 1
        expect(PaidLeaveBalance.exists?(effective_from: "2026-04-01")).to be true
      end
    end

    context "1つのgrant,2つのrule,それぞれgrant期間内開始の場合" do
      let!(:rule_20260401) { FactoryBot.create(:employee_rule, employee:, effective_from: "2026-04-01", expires_on: "2027-03-31") }
      let!(:rule_20270401) { FactoryBot.create(:employee_rule, employee:, effective_from: "2027-04-01", expires_on: "2028-03-31") }

      it "2つのBalanceが生成される" do
        described_class.for_new_paid_leave_grant!(grant)
        expect(PaidLeaveBalance.all.count).to eq 2
        expect(PaidLeaveBalance.exists?(effective_from: "2026-04-01")).to be true
        expect(PaidLeaveBalance.exists?(effective_from: "2027-04-01")).to be true
      end
    end

    context "1つのgrant,2つのrule,それぞれruleの期間外だった場合" do
      let!(:rule_20250401) { FactoryBot.create(:employee_rule, employee:, effective_from: "2025-04-01", expires_on: "2026-03-31") }
      let!(:rule_20280401) { FactoryBot.create(:employee_rule, employee:, effective_from: "2028-04-01", expires_on: "2029-03-31") }

      it "Balanceが生成されない" do
        described_class.for_new_paid_leave_grant!(grant)
        expect(PaidLeaveBalance.all.count).to eq 0
      end
    end
  end



  describe "for_new_employee_rule!" do
    let(:employee) { FactoryBot.create(:employee) }
    let!(:rule) { FactoryBot.create(:employee_rule, employee:, effective_from: "2026-04-01", expires_on: "2028-03-31") }


    context "1つのrule,1つのgrant,それぞれ2026/04/01開始の場合" do
      let!(:grant_20260401) { FactoryBot.create(:paid_leave_grant, employee:, granted_by: employee, granted_on: "2026-04-01", expires_on: "2028-03-31") }

      it "2026/04/01開始のBalanceが生成される" do
        described_class.for_new_employee_rule!(rule)
        expect(PaidLeaveBalance.all.count).to eq 1
        expect(PaidLeaveBalance.exists?(effective_from: "2026-04-01")).to be true
      end
    end
    context "1つのrule,1つのgrant, 26年8月開始のgrantに対して26年4月開始のruleが作られた場合" do
      let!(:grant_20260801) { FactoryBot.create(:paid_leave_grant, employee:, granted_by: employee, granted_on: "2026-08-01", expires_on: "2028-03-31") }

      it "2026/08/01開始のBalanceが生成される" do
        described_class.for_new_employee_rule!(rule)
        expect(PaidLeaveBalance.all.count).to eq 1
        expect(PaidLeaveBalance.exists?(effective_from: "2026-08-01")).to be true
      end
    end

    context "1つのrule,1つのgrant,25年開始のgrantに対して26年開始のruleが作られた場合" do
      let!(:grant_20250401) { FactoryBot.create(:paid_leave_grant, employee:, granted_by: employee, granted_on: "2025-04-01", expires_on: "2027-03-31") }

      it "2026/04/01開始のBalanceが生成される" do
        described_class.for_new_employee_rule!(rule)
        expect(PaidLeaveBalance.all.count).to eq 1
        expect(PaidLeaveBalance.exists?(effective_from: "2026-04-01")).to be true
      end
    end

    context "1つのrule,2つのgrant,それぞれrule期間内開始の場合" do
      let!(:grant_20260401) { FactoryBot.create(:paid_leave_grant, employee:, granted_by: employee, granted_on: "2026-04-01", expires_on: "2028-03-31") }
      let!(:grant_20270401) { FactoryBot.create(:paid_leave_grant, employee:, granted_by: employee, granted_on: "2027-04-01", expires_on: "2029-03-31") }

      it "2つのBalanceが生成される" do
        described_class.for_new_employee_rule!(rule)
        expect(PaidLeaveBalance.all.count).to eq 2
        expect(PaidLeaveBalance.exists?(effective_from: "2026-04-01")).to be true
        expect(PaidLeaveBalance.exists?(effective_from: "2027-04-01")).to be true
      end
    end

    context "1つのgrant,2つのrule,それぞれruleの期間外だった場合" do
      let!(:grant_20240401) { FactoryBot.create(:paid_leave_grant, employee:, granted_by: employee, granted_on: "2024-04-01", expires_on: "2026-03-31") }
      let!(:grant_20280401) { FactoryBot.create(:paid_leave_grant, employee:, granted_by: employee, granted_on: "2028-04-01", expires_on: "2030-03-31") }

      it "Balanceが生成されない" do
        described_class.for_new_employee_rule!(rule)
        expect(PaidLeaveBalance.all.count).to eq 0
      end
    end
  end
end

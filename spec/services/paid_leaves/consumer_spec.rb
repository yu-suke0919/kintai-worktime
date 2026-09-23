require 'rails_helper'

RSpec.describe PaidLeaves::Consumer, type: :service do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@gmail.com", role: :manager) }
  # let(:exception_request) { FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: :paid_leave) }
  # let(:exception) { FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request, exception_type: :paid_leave) }

  # let(:balance) { FactoryBot.create(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule, effective_from: Date.new(2026, 4, 1)) }
  # let(:transaction) { FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance, delta_days: 1, work_date_exception: exception) }
  describe "consume" do
    # 付与された有給休暇の残りを1日、1時間単位で返す関数
    # 5日と4時間であれば、{days => 5,hours => 4}が返却値となる。
    context "有給休暇がない" do
      it "「有給休暇が付与されていません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave")
        exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave")
        expect {
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
      }.to raise_error(RuntimeError, "有給休暇が付与されていません")
      end
    end

    context "有給残高が残り1時間" do
      let!(:grant) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 1) }
      let!(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
      let(:balance_1) { grant.balances.first }

      before do
        exception_request_7hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 2, 9, 0, 0), ends_at: DateTime.new(2026, 4, 2, 16, 0, 0))
        exception_1_7hour_paid_leave = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_7hour_paid_leave, exception_type: "hourly_paid_leave")
        FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_minutes: 420, work_date_exception: exception_1_7hour_paid_leave)
      end
      it "有給残り1時間の時に1時間の有給取得を試みてエラーが出ない" do
        exception_request_1hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 3, 9, 0, 0), ends_at: DateTime.new(2026, 4, 2, 13, 0, 0))
        exception_1_1hour_paid_leave = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1hour_paid_leave, exception_type: "hourly_paid_leave")
        expect {
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1_1hour_paid_leave)
        }.not_to raise_error
      end
      it "有給残り1時間の時に1日の有給取得を試みて「有給残高が足りません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave")
        exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave")
        expect {
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
        }.to raise_error(RuntimeError, "有給残高が足りません")
      end
      it "有給残り1時間の時に4時間の有給取得を試みて「有給残高が足りません」と出る" do
        exception_request_4hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 3, 9, 0, 0), ends_at: DateTime.new(2026, 4, 2, 13, 0, 0))
        exception_1_4hour_paid_leave = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_4hour_paid_leave, exception_type: "hourly_paid_leave")
        expect {
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1_4hour_paid_leave)
        }.to raise_error(RuntimeError, "有給残高が足りません")
      end
    end

    context "有給残高が残り2日" do
      let!(:grant) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 2) }
      let!(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
      let(:balance_1) { grant.balances.first }

      before do
      end
      it "有給残り2日の時に2日連続した有給取得を試みて、エラーが出ず成功する" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 4))
        expect {
          exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave", work_date: Date.new(2026, 4, 3))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
          exception_2 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave", work_date: Date.new(2026, 4, 4))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_2)
        }.not_to raise_error
      end
      it "有給残り2日の時に3日連続した有給取得を試みて、「有給残高が足りません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 5))

        expect {
          exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave", work_date: Date.new(2026, 4, 3))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
          exception_2 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave", work_date: Date.new(2026, 4, 4))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_2)
          exception_3 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave", work_date: Date.new(2026, 4, 5))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_3)
        }.to raise_error(RuntimeError, "有給残高が足りません")
      end
    end
    describe "create_transactions!" do
    end
    describe "create_transaction" do
    end

    # context "有給休暇申請が行われており、同じ就業時間ルール内で申請されている。" do
    #   let(:grant) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 10) }
    #   let(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
    #   let(:balance_1) { FactoryBot.create(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule_fulltime, effective_from: Date.new(2026, 4, 1)) }

    #   it "1日の有給使用により、有給残高は9日に変化" do
    #     exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave")
    #     exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_days: 1, work_date_exception: exception_1)

    #     result = PaidLeaves::BalanceCalculator.new(grant: grant).remaining_leaves
    #     expect(result[:days]).to eq(9)
    #     expect(result[:hours]).to eq(0)
    #   end
    #   it "6時間の有給使用により、有給残高は9日2時間に変化" do
    #     exception_request_2 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 5, 2, 9, 0, 0), ends_at: DateTime.new(2026, 5, 2, 15, 0, 0))
    #     exception_2 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_2, exception_type: "hourly_paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_minutes: 360, work_date_exception: exception_2)
    #     result = PaidLeaves::BalanceCalculator.new(grant: grant).remaining_leaves
    #     expect(result[:days]).to eq(9)
    #     expect(result[:hours]).to eq(2)
    #   end
    #   it "1日と5時間の有給使用により、有給残高は8日3時間に変化" do
    #     exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave")
    #     exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_days: 1, work_date_exception: exception_1)
    #     exception_request_2 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 5, 2, 9, 0, 0), ends_at: DateTime.new(2026, 5, 2, 15, 0, 0))
    #     exception_2 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_2, exception_type: "hourly_paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_minutes: 300, work_date_exception: exception_2)
    #     result = PaidLeaves::BalanceCalculator.new(grant: grant).remaining_leaves
    #     expect(result[:days]).to eq(8)
    #     expect(result[:hours]).to eq(3)
    #   end
    # end

    # context "有給休暇申請が行われており、異なる就業時間ルール内で申請されている。" do
    #   let(:grant) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 10) }
    #   let(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480, effective_from: Date.new(2026, 4, 1), expires_on: Date.new(2026, 4, 30)) }
    #   let(:balance_1) { FactoryBot.create(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule_fulltime, effective_from: Date.new(2026, 4, 1)) }
    #   let(:user_rule_six_hour_time) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 360, effective_from: Date.new(2026, 5, 1), expires_on: Date.new(2026, 5, 31)) }
    #   let(:balance_2) { FactoryBot.create(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule_six_hour_time, effective_from: Date.new(2026, 5, 1)) }
    #   let(:user_rule_seven_hour_time) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 420, effective_from: Date.new(2026, 6, 1), expires_on: Date.new(2026, 6, 30)) }
    #   let(:balance_3) { FactoryBot.create(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule_seven_hour_time, effective_from: Date.new(2026, 6, 1)) }

    #   it "8時間勤務時に1日,6時間勤務時に1日の有給使用により、有給残高は8日に変化" do
    #     exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 2), end_date: Date.new(2026, 4, 2))
    #     exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_days: 1, work_date_exception: exception_1)
    #     exception_request_2 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 5, 2), end_date: Date.new(2026, 5, 2))
    #     exception_2 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_2, exception_type: "paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_2, delta_days: 1, work_date_exception: exception_2)

    #     result = PaidLeaves::BalanceCalculator.new(grant: grant).remaining_leaves
    #     expect(result[:days]).to eq(8)
    #     expect(result[:hours]).to eq(0)
    #   end
    #   it "8時間勤務時に4時間,6時間勤務時に3時間の有給使用により、有給残高は9日0時間(勤務時間変更時に端数切り上げなし)に変化" do
    #     exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 2, 9, 0, 0), ends_at: DateTime.new(2026, 4, 2, 13, 0, 0))
    #     exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "hourly_paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_minutes: 240, work_date_exception: exception_1)
    #     exception_request_2 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave",  starts_at: DateTime.new(2026, 5, 2, 9, 0, 0), ends_at: DateTime.new(2026, 5, 2, 12, 0, 0))
    #     exception_2 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_2, exception_type: "hourly_paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_2, delta_minutes: 180,  work_date_exception: exception_2)

    #     result = PaidLeaves::BalanceCalculator.new(grant: grant).remaining_leaves
    #     expect(result[:days]).to eq(9)
    #     expect(result[:hours]).to eq(0)
    #   end
    #   it "8時間勤務時に2時間,6時間勤務時に1日の有給使用により、有給残高は8日5時間(勤務時間変更時に端数切り上げあり)に変化" do
    #     exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 2, 9, 0, 0), ends_at: DateTime.new(2026, 4, 2, 11, 0, 0))
    #     exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "hourly_paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_minutes: 120, work_date_exception: exception_1)
    #     exception_request_2 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 5, 2), end_date: Date.new(2026, 5, 2))
    #     exception_2 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_2, exception_type: "paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_2, delta_days: 1, work_date_exception: exception_2)

    #     result = PaidLeaves::BalanceCalculator.new(grant: grant).remaining_leaves
    #     expect(result[:days]).to eq(8)
    #     expect(result[:hours]).to eq(5)
    #   end
    #   it "6時間勤務時に1時間,7時間勤務時に5時間の有給使用により、有給残高は9日1時間に変化" do
    #     exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 5, 2, 9, 0, 0), ends_at: DateTime.new(2026, 5, 2, 10, 0, 0))
    #     exception_1 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_1, exception_type: "hourly_paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_2, delta_minutes: 60, work_date_exception: exception_1)
    #     exception_request_2 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 6, 2, 9, 0, 0), ends_at: DateTime.new(2026, 6, 2, 14, 0, 0))
    #     exception_2 = FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request_2, exception_type: "hourly_paid_leave")
    #     FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_3, delta_minutes: 300, work_date_exception: exception_2)
    #     result = PaidLeaves::BalanceCalculator.new(grant: grant).remaining_leaves
    #     expect(result[:days]).to eq(9)
    #     expect(result[:hours]).to eq(1)
    #   end
    # end
  end
end

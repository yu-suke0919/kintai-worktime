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
        exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 2))
        expect {
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
      }.to raise_error(RuntimeError, "有給休暇が付与されていません")
      end
    end

    context "取得テスト_有給残高が残り1時間" do
      let!(:grant) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 1) }
      let!(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
      let(:balance_1) { grant.balances.first }

      before do
        exception_request_7hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 2, 9, 0, 0), ends_at: DateTime.new(2026, 4, 2, 16, 0, 0))
        exception_1_7hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_7hour_paid_leave)
        FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_minutes: 420, work_date_exception: exception_1_7hour_paid_leave)
      end
      it "有給残り1時間の時に1時間の有給取得を試みてエラーが出ない" do
        exception_request_1hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 3, 9, 0, 0), ends_at: DateTime.new(2026, 4, 3, 10, 0, 0))
        exception_1_1hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_1hour_paid_leave)
        expect {
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1_1hour_paid_leave)
        }.not_to raise_error
      end
      it "有給残り1時間の時に1日の有給取得を試みて「有給残高が足りません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 2), end_date: Date.new(2026, 4, 2))
        exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 2))
        expect {
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
        }.to raise_error(RuntimeError, "有給残高が足りません")
      end
      it "有給残り1時間の時に4時間の有給取得を試みて「有給残高が足りません」と出る" do
        exception_request_4hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 3, 9, 0, 0), ends_at: DateTime.new(2026, 4, 3, 13, 0, 0))
        exception_1_4hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_4hour_paid_leave)
        expect {
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1_4hour_paid_leave)
        }.to raise_error(RuntimeError, "有給残高が足りません")
      end
    end

    context "取得テスト_有給残高が残り2日" do
      let!(:grant) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 2) }
      let!(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
      let(:balance_1) { grant.balances.first }

      before do
      end
      it "有給残り2日の時に2日連続した有給取得を試みて、エラーが出ず成功する" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 4))
        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_2)
        }.not_to raise_error
      end
      it "有給残り2日の時に3日連続した有給取得を試みて、「有給残高が足りません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 5))

        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_2)
          exception_3 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 5))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_3)
        }.to raise_error(RuntimeError, "有給残高が足りません")
      end
    end
    context "取得テスト_有給残高が残り4時間、残り2日の2つがある" do
      let!(:grant1) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 1, granted_on: Date.new(2025, 4, 1), expires_on: Date.new(2027, 3, 31)) }
      let!(:grant2) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 2, granted_on: Date.new(2026, 4, 1), expires_on: Date.new(2028, 3, 31)) }
      let!(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
      let(:balance_1) { grant1.balances.first }

      before do
        exception_request_4hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 2, 9, 0, 0), ends_at: DateTime.new(2026, 4, 2, 13, 0, 0))
        exception_1_4hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_4hour_paid_leave)
        FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance_1, delta_minutes: 240, work_date_exception: exception_1_4hour_paid_leave)
      end
      it "before do の内容が適用(grant1の残高を消費)しているか" do
        expect(grant1.remaining_leaves[:days]).to eq(0)
        expect(grant1.remaining_leaves[:hours]).to eq(4)
        expect(grant2.remaining_leaves[:days]).to eq(2)
        expect(grant2.remaining_leaves[:hours]).to eq(0)
      end
      it "有給残り4時間+2日の時に1日の有給取得を試みて、エラーが出ず成功し、grant2に1日と4時間が残っている" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 3))
        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
        }.not_to raise_error

        expect(grant1.remaining_leaves[:days]).to eq(0)
        expect(grant1.remaining_leaves[:hours]).to eq(0)
        expect(grant2.remaining_leaves[:days]).to eq(1)
        expect(grant2.remaining_leaves[:hours]).to eq(4)
      end
      it "有給残り4時間+2日の時に2日連続した有給取得を試みて、エラーが出ず成功し、grant2に4時間が残っている" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 4))
        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_2)
        }.not_to raise_error

        expect(grant1.remaining_leaves[:days]).to eq(0)
        expect(grant1.remaining_leaves[:hours]).to eq(0)
        expect(grant2.remaining_leaves[:days]).to eq(0)
        expect(grant2.remaining_leaves[:hours]).to eq(4)
      end
      it "有給残り2日の時に3日連続した有給取得を試みて、「有給残高が足りません」と出る。また、残高は消費されない" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 5))

        expect {
          ApplicationRecord.transaction do
            exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
            PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
            exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
            PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_2)
            exception_3 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 5))
            PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_3)
          end
        }.to raise_error(RuntimeError, "有給残高が足りません")
        expect(grant1.remaining_leaves[:days]).to eq(0)
        expect(grant1.remaining_leaves[:hours]).to eq(4)
        expect(grant2.remaining_leaves[:days]).to eq(2)
        expect(grant2.remaining_leaves[:hours]).to eq(0)
      end
    end

    context "履歴積みなおし_有給残高が2025年に配られた2日(残り1日)と2026年に配られた10日(残り10日)がある" do
      let!(:grant1) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 2, granted_on: Date.new(2025, 4, 1), expires_on: Date.new(2027, 3, 31)) }
      let!(:grant2) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 10, granted_on: Date.new(2026, 4, 1), expires_on: Date.new(2028, 3, 31)) }
      let!(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
      let(:balance_1) { grant1.balances.first }
      let(:balance_2) { grant2.balances.first }

      before do
        exception_request_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", start_date: Date.new(2026, 5, 3), end_date: Date.new(2026, 5, 3))
        exception_1_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_paid_leave)
        PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1_paid_leave)
      end
      it "残りの残高が1日と10日で、残り残高1に5月3日のtransactionがある" do
        expect(grant1.remaining_leaves).to eq({ days: 1, hours: 0 })
        except(balance_1.transactions.count).to eq(1)
        expect(balance_1.transactions.first.effective_on).to eq(Date.new(2026, 5, 3))
        expect(grant1.remaining_leaves).to eq({ days: 10, hours: 0 })
        except(balance_1.transactions.count).to eq(0)
      end

      it "有給残り2日の時に2日連続した有給取得を試みて、エラーが出ず成功する" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 4))
        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_2)
        }.not_to raise_error
      end
      it "有給残り2日の時に3日連続した有給取得を試みて、「有給残高が足りません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 5))

        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_1)
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_2)
          exception_3 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 5))
          PaidLeaves::Consumer.new(employee: user_1).consume(new_exception: exception_3)
        }.to raise_error(RuntimeError, "有給残高が足りません")
      end
    end
  end
end

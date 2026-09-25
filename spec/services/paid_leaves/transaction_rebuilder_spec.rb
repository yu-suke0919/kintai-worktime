require 'rails_helper'

RSpec.describe PaidLeaves::TransactionRebuilder, type: :service do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@gmail.com", role: :manager) }
  # let(:exception_request) { FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: :paid_leave) }
  # let(:exception) { FactoryBot.create(:work_date_exception, employee: user_1, work_date_exception_request: exception_request, exception_type: :paid_leave) }

  # let(:balance) { FactoryBot.create(:paid_leave_balance, paid_leave_grant: grant, employee_rule: user_rule, effective_from: Date.new(2026, 4, 1)) }
  # let(:transaction) { FactoryBot.create(:paid_leave_transaction, paid_leave_balance: balance, delta_days: 1, work_date_exception: exception) }
  describe "execute" do
    # 付与された有給休暇の残りを1日、1時間単位で返す関数
    # 5日と4時間であれば、{days => 5,hours => 4}が返却値となる。
    context "有給休暇がない" do
      it "「有給休暇が付与されていません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave")
        exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 2))
        expect {
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
      }.to raise_error(RuntimeError, "有給休暇が付与されていません")
      end
    end

    context "取得テスト_残高が残り1時間" do
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
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1_1hour_paid_leave.work_date).execute()
        }.not_to raise_error
      end
      it "有給残り1時間の時に1日の有給取得を試みて「残高が足りません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 2), end_date: Date.new(2026, 4, 2))
        exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 2))
        expect {
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
        }.to raise_error(RuntimeError, "残高が足りません")
      end
      it "有給残り1時間の時に4時間の有給取得を試みて「残高が足りません」と出る" do
        exception_request_4hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 3, 9, 0, 0), ends_at: DateTime.new(2026, 4, 3, 13, 0, 0))
        exception_1_4hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_4hour_paid_leave)
        expect {
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1_4hour_paid_leave.work_date).execute()
        }.to raise_error(RuntimeError, "残高が足りません")
      end
    end

    context "取得テスト_残高が残り2日" do
      let!(:grant) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 2) }
      let!(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
      let(:balance_1) { grant.balances.first }

      before do
      end
      it "有給残り2日の時に2日連続した有給取得を試みて、エラーが出ず成功する" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 4))
        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
        }.not_to raise_error
      end
      it "有給残り2日の時に3日連続した有給取得を試みて、「残高が足りません」と出る" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 5))

        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          exception_3 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 5))
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
        }.to raise_error(RuntimeError, "残高が足りません")
      end
    end
    context "取得テスト_残高が残り4時間、残り2日の2つがある" do
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
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
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
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
        }.not_to raise_error

        expect(grant1.remaining_leaves[:days]).to eq(0)
        expect(grant1.remaining_leaves[:hours]).to eq(0)
        expect(grant2.remaining_leaves[:days]).to eq(0)
        expect(grant2.remaining_leaves[:hours]).to eq(4)
      end
      it "有給残り2日の時に3日連続した有給取得を試みて、「残高が足りません」と出る。また、残高は消費されない" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 5))

        expect {
          ApplicationRecord.transaction do
            exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
            exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
            exception_3 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 5))
            PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
          end
        }.to raise_error(RuntimeError, "残高が足りません")
        expect(grant1.remaining_leaves[:days]).to eq(0)
        expect(grant1.remaining_leaves[:hours]).to eq(4)
        expect(grant2.remaining_leaves[:days]).to eq(2)
        expect(grant2.remaining_leaves[:hours]).to eq(0)
      end
    end

    context "履歴積みなおし_残高が2025年に配られた2日(残り1日)と2026年に配られた10日(残り10日)がある" do
      let!(:grant1) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 2, granted_on: Date.new(2025, 4, 1), expires_on: Date.new(2027, 3, 31)) }
      let!(:grant2) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 10, granted_on: Date.new(2026, 4, 1), expires_on: Date.new(2028, 3, 31)) }
      let!(:user_rule_fulltime) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480) }
      let(:balance_1) { grant1.balances.first }
      let(:balance_2) { grant2.balances.first }

      before do
        exception_request_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 5, 3), end_date: Date.new(2026, 5, 3))
        exception_1_paid_leave = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_paid_leave, work_date: Date.new(2026, 5, 3))
        PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1_paid_leave.work_date).execute()
      end
      it "残りの残高が1日と10日で、残り残高1に5月3日のtransactionがある" do
        expect(grant1.remaining_leaves).to eq({ days: 1, hours: 0 })
        expect(balance_1.transactions.count).to eq(1)
        expect(balance_1.transactions.first.effective_on).to eq(Date.new(2026, 5, 3))
        expect(grant2.remaining_leaves).to eq({ days: 10, hours: 0 })
        expect(balance_2.transactions.count).to eq(0)
      end

      it "4月3~4日の有給を取得した時、5月3日の有給は積み直されてgrant2の残高を利用する" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 4))
        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          exception_2 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 4))
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
        }.not_to raise_error
        expect(grant1.remaining_leaves).to eq({ days: 0, hours: 0 })
        expect(balance_1.transactions.count).to eq(2)
        expect(balance_1.transactions.find_by(effective_on: Date.new(2026, 4, 3))).to be_present
        expect(balance_1.transactions.find_by(effective_on: Date.new(2026, 4, 4))).to be_present

        expect(grant2.remaining_leaves).to eq({ days: 9, hours: 0 })
        expect(balance_2.transactions.count).to eq(1)
        expect(balance_2.transactions.find_by(effective_on: Date.new(2026, 5, 3))).to be_present
      end

      it "4月3日に終日、4日に4時間の有給を取得した時、5月3日の有給は積み直されて4時間分grant2の残高を利用する" do
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 3), end_date: Date.new(2026, 4, 3))
        exception_request_4hour_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 4, 9, 0, 0), ends_at: DateTime.new(2026, 4, 4, 13, 0, 0))

        expect {
          exception_1 = FactoryBot.create(:work_date_exception, :paid_leave, employee: user_1, work_date_exception_request: exception_request_1, work_date: Date.new(2026, 4, 3))
          exception_2 = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_4hour_paid_leave)
          PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_1.work_date).execute()
        }.not_to raise_error
        expect(grant1.remaining_leaves).to eq({ days: 0, hours: 0 })
        expect(balance_1.transactions.count).to eq(3)
        expect(balance_1.transactions.find_by(effective_on: Date.new(2026, 4, 3))).to be_present
        expect(balance_1.transactions.find_by(effective_on: Date.new(2026, 4, 3)).delta_days).to eq(1)
        expect(balance_1.transactions.find_by(effective_on: Date.new(2026, 4, 4))).to be_present
        expect(balance_1.transactions.find_by(effective_on: Date.new(2026, 4, 4)).delta_minutes).to eq(240)
        expect(balance_1.transactions.find_by(effective_on: Date.new(2026, 5, 3))).to be_present
        expect(balance_1.transactions.find_by(effective_on: Date.new(2026, 5, 3)).delta_minutes).to eq(240)

        expect(grant2.remaining_leaves).to eq({ days: 9, hours: 4 })
        expect(balance_2.transactions.count).to eq(1)
        expect(balance_2.transactions.find_by(effective_on: Date.new(2026, 5, 3))).to be_present
        expect(balance_2.transactions.find_by(effective_on: Date.new(2026, 5, 3)).delta_days).to eq(0)
        expect(balance_2.transactions.find_by(effective_on: Date.new(2026, 5, 3)).delta_minutes).to eq(240)
      end
    end

    context "履歴積みなおし_残高が2025年に配られた2日(残り1日と3時間)と2026年に配られた10日(残り10日)があり、２回ルールが変更されている" do
      let!(:grant1) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 2, granted_on: Date.new(2024, 4, 1), expires_on: Date.new(2026, 3, 31)) }
      let!(:grant2) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 10, granted_on: Date.new(2026, 4, 1), expires_on: Date.new(2028, 3, 31)) }
      let!(:user_rule_short_time_from_1_1_to_2_28) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 360, effective_from: Date.new(2026, 1, 1), expires_on: Date.new(2026, 2, 28)) }
      let!(:user_rule_full_time_from_3_1_to_4_30) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 480, effective_from: Date.new(2026, 3, 1), expires_on: Date.new(2026, 4, 30)) }
      let!(:user_rule_short_time_from_5_1_to_6_30) { FactoryBot.create(:employee_rule, employee: user_1, scheduled_work_minutes: 360, effective_from: Date.new(2026, 5, 1), expires_on: Date.new(2026, 6, 30)) }
      let(:balance_1_from_1_1) { grant1.balances.find_by(effective_from: Date.new(2026, 1, 1)) }
      let(:balance_2_from_3_1) { grant1.balances.find_by(effective_from: Date.new(2026, 3, 1)) }
      let(:balance_3_from_4_1) { grant2.balances.find_by(effective_from: Date.new(2026, 4, 1)) }
      let(:balance_4_from_5_1) { grant2.balances.find_by(effective_from: Date.new(2026, 5, 1)) }

      before do
        exception_request_hourly_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 1, 2, 9, 0, 0), ends_at: DateTime.new(2026, 1, 2, 12, 0, 0))
        exception_request_3hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_hourly_paid_leave)
        PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_request_3hour_paid_leave.work_date).execute()
      end

      it "Balanceが正常に4つに分かれている" do
        expect(balance_1_from_1_1).to be_present
        expect(balance_2_from_3_1).to be_present
        expect(balance_3_from_4_1).to be_present
        expect(balance_4_from_5_1).to be_present
      end
      it "[1日と3時間,10日]がフルタイムになった時に1日の単位時間が6→8に増えるため、現在の残高も増えて残りの残高が[1日と4時間,10日]" do
        expect(grant1.remaining_leaves).to eq({ days: 1, hours: 4 })
        expect(balance_1_from_1_1.transactions.count).to eq(1)
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 1, 2))).to be_present
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 1, 2)).delta_minutes).to eq(180)
      end

      it "フルタイム時に有給4時間を取得、有給の単位が変わり[1日4時間,10日]になりそこから4時間引かれて、残りの残高が[1日,10日]になる" do
        exception_request_hourly_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 3, 2, 9, 0, 0), ends_at: DateTime.new(2026, 3, 2, 13, 0, 0))
        exception_request_4hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_hourly_paid_leave)
        PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_request_4hour_paid_leave.work_date).execute()

        expect(grant1.remaining_leaves).to eq({ days: 1, hours: 0 })
        expect(balance_1_from_1_1.transactions.count).to eq(1)
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 1, 2))).to be_present
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 1, 2)).delta_minutes).to eq(180)

        expect(balance_2_from_3_1.transactions.count).to eq(1)
        expect(balance_2_from_3_1.transactions.find_by(effective_on: Date.new(2026, 3, 2))).to be_present
        expect(balance_2_from_3_1.transactions.find_by(effective_on: Date.new(2026, 3, 2)).delta_minutes).to eq(240)
      end

      it "フルタイム前の時短勤務時に追加で有給3時間を取得、残りの残高が[1日,10日]になる" do
        exception_request_hourly_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 2, 2, 9, 0, 0), ends_at: DateTime.new(2026, 2, 2, 12, 0, 0))
        exception_request_3hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_hourly_paid_leave)
        PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_request_3hour_paid_leave.work_date).execute()

        expect(grant1.remaining_leaves).to eq({ days: 1, hours: 0 })
        expect(balance_1_from_1_1.transactions.count).to eq(2)
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 1, 2))).to be_present
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 1, 2)).delta_minutes).to eq(180)
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 2, 2))).to be_present
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 2, 2)).delta_minutes).to eq(180)
      end
      it "フルタイム前の時短勤務時に追加で有給2時間を取得、残りの残高が[1日1時間,10日]になり、フルタイム時の変換で時間が繰り上がり、[1日2時間,10日]となる" do
        exception_request_hourly_paid_leave = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 2, 2, 9, 0, 0), ends_at: DateTime.new(2026, 2, 2, 11, 0, 0))
        exception_request_2hour_paid_leave = FactoryBot.create(:work_date_exception, :hourly_paid_leave, employee: user_1, work_date_exception_request: exception_request_hourly_paid_leave)
        PaidLeaves::TransactionRebuilder.new(employee: user_1, work_date: exception_request_2hour_paid_leave.work_date).execute()

        expect(grant1.remaining_leaves).to eq({ days: 1, hours: 2 })
        expect(balance_1_from_1_1.transactions.count).to eq(2)
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 1, 2))).to be_present
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 1, 2)).delta_minutes).to eq(180)
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 2, 2))).to be_present
        expect(balance_1_from_1_1.transactions.find_by(effective_on: Date.new(2026, 2, 2)).delta_minutes).to eq(120)
      end
    end
  end
end

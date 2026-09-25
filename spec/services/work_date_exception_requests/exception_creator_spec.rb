require 'rails_helper'

RSpec.describe WorkDateExceptionRequests::ExceptionCreator, type: :service do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@gmail.com", role: :manager) }

  describe "for_new_paid_leave_grant!" do
    let!(:grant) { FactoryBot.create(:paid_leave_grant, employee: user_1, granted_by: user_manager, granted_days: 1) }

    context "有給休暇の取得(残高1日)" do
      let!(:rule_20260401) { FactoryBot.create(:employee_rule, employee: user_1, effective_from: grant.granted_on, expires_on: grant.expires_on) }

      it "1日の有給休暇を取得してエラーが出ず就業日例外が生成される。" do
        expect(grant.remaining_leaves).to eq(days: 1, hours: 0)
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 2), end_date: Date.new(2026, 4, 2))
        WorkDateExceptionRequests::ExceptionCreator.new(exception_request: exception_request_1).call()
        expect(grant.remaining_leaves).to eq(days: 0, hours: 0)
        expect(user_1.work_date_exceptions.find_by(work_date: Date.new(2026, 4, 2))).to be_present
      end

      it "2日の有給休暇を取得してエラーが出て就業日例外が生成されない。" do
        expect(grant.remaining_leaves).to eq(days: 1, hours: 0)
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 2), end_date: Date.new(2026, 4, 3))
        expect {
          WorkDateExceptionRequests::ExceptionCreator.new(exception_request: exception_request_1).call()
        }.to raise_error(WorkDateExceptionRequests::ExceptionCreator::CreationError, "残高が足りません")
        expect(grant.remaining_leaves).to eq(days: 1, hours: 0)
        expect(user_1.work_date_exceptions.count).to eq(0)
      end

      it "2時間の有給休暇を取得してエラーが出ず就業日例外が生成される。" do
        expect(grant.remaining_leaves).to eq(days: 1, hours: 0)
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 3, 9, 0, 0), ends_at: DateTime.new(2026, 4, 3, 11, 0, 0))
        WorkDateExceptionRequests::ExceptionCreator.new(exception_request: exception_request_1).call()
        expect(grant.remaining_leaves).to eq(days: 0, hours: 6)
        expect(user_1.work_date_exceptions.find_by(work_date: Date.new(2026, 4, 3))).to be_present
      end

      it "1日の有給休暇を取得したあと、2時間の有給取得をしてエラーが出て就業日例外が生成されない。" do
        expect(grant.remaining_leaves).to eq(days: 1, hours: 0)
        exception_request_1 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "paid_leave", start_date: Date.new(2026, 4, 2), end_date: Date.new(2026, 4, 2))
        WorkDateExceptionRequests::ExceptionCreator.new(exception_request: exception_request_1).call()

        expect(grant.remaining_leaves).to eq(days: 0, hours: 0)
        exception_request_2 = FactoryBot.create(:work_date_exception_request, employee: user_1, request_type: "hourly_paid_leave", starts_at: DateTime.new(2026, 4, 3, 9, 0, 0), ends_at: DateTime.new(2026, 4, 3, 11, 0, 0))
        expect {
          WorkDateExceptionRequests::ExceptionCreator.new(exception_request: exception_request_2).call()
        }.to raise_error(WorkDateExceptionRequests::ExceptionCreator::CreationError, "残高が足りません")
        expect(grant.remaining_leaves).to eq(days: 0, hours: 0)
        expect(user_1.work_date_exceptions.count).to eq(1)
      end
    end
  end
end

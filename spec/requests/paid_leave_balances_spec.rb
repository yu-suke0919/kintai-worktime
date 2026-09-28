require 'rails_helper'

RSpec.describe "PaidLeaveBalances", type: :request do
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@email", role: :manager) }
  let(:user_not_manager) { FactoryBot.create(:employee) }
  let(:user_rule) { FactoryBot.create(:employee_rule, employee: user_not_manager) }
  let(:paid_leave_grant) { FactoryBot.create(:paid_leave_grant, employee: user_not_manager, granted_by: user_manager, granted_on: Date.new(2026, 4, 1)) }

  shared_examples "redirect_to_login_page" do
    it "ログインページにリダイレクトされ、alertが設定されること" do
      request_action
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_employee_session_path)
      expect(flash[:alert]).to be_present
    end
  end

  shared_examples "redirect_to_current_employee_attendance_index_page" do
    it "ログイン中の従業員勤怠画面にリダイレクトされ、alertが設定されること" do
      request_action
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(employee_attendances_path(logged_in_employee))
      expect(flash[:alert]).to be_present
    end
  end

  shared_examples "have_http_status_success" do
    it "HTTPリクエストステータスが成功していること" do
      request_action
      expect(response).to have_http_status(:success)
    end
  end


  describe "GET /index" do
    let(:request_action) { get paid_leave_grant_paid_leave_balances_path(paid_leave_grant) }
    context "非ログイン時" do
      it_behaves_like "redirect_to_login_page"
    end
    context "ログイン中ユーザーでないユーザーの有給ページを見る時" do
      let(:logged_in_employee) { user_manager }
      before do
        sign_in user_manager
      end
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end
    context "ログイン中のユーザーが自身のページを見る時" do
      let(:logged_in_employee) { user_not_manager }
      before do
        sign_in user_not_manager
      end
      it_behaves_like "have_http_status_success"
      # 画面の要素が適切かどうか
      it "適切な画面表示が表示されること" do
        request_action
        expect(response.body).to include("有給付与日")
        expect(response.body).to include("2026-04-01")
      end
    end
  end
end

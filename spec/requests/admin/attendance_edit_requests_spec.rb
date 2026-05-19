require 'rails_helper'

RSpec.describe "Admin::AttendanceEditRequests", type: :request do
  let(:user_not_manager) { FactoryBot.create(:employee) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@email", role: :manager) }

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
      expect(response).to redirect_to(employee_attendances_url(logged_in_employee))
      expect(flash[:alert]).to be_present
    end
  end

    shared_examples "have_http_status_success" do
    it "HTTPリクエストステータスが、成功となること" do
      request_action
      expect(response).to have_http_status(:success)
    end
  end

  context "非ログイン時" do
    describe "GET /admin/employee/[user_not_manager.id]/attendance_edit_request/index" do
      let(:request_action) { get admin_employee_attendance_edit_requests_path(user_not_manager) }
      it_behaves_like "redirect_to_login_page"
    end

    describe "GET /admin/employee/[user_not_manager.id]/attendance_edit_request/show" do
      let(:request_action) { get admin_employee_attendance_edit_request_path(user_not_manager, Date.current) }
      it_behaves_like "redirect_to_login_page"
    end
  end
  context "manager権限なしUserがログイン時" do
    before do
      sign_in user_not_manager
    end
    describe "GET /admin/employee/[user_not_manager.id]/attendance_edit_request/index" do
      let(:request_action) { get admin_employee_attendance_edit_requests_path(user_not_manager) }
      let(:logged_in_employee) { user_not_manager }
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end

    describe "GET /admin/employee/[user_not_manager.id]/attendance_edit_request/show" do
      let(:request_action) { get admin_employee_attendance_edit_request_path(user_not_manager, Date.current) }
      let(:logged_in_employee) { user_not_manager }
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end
  end

  context "manager権限ありマネージャーがログイン時" do
    before do
      sign_in user_manager
    end
    describe "GET /admin/employee/[user_manager.id]/attendance_edit_request/index" do
      let(:request_action) { get admin_employee_attendance_edit_requests_path(user_not_manager) }
      let(:logged_in_employee) { user_manager }
      it_behaves_like "have_http_status_success"
    end

    describe "GET /admin/employee/[user_manager.id]/attendance_edit_request/show" do
      let(:request_action) { get admin_employee_attendance_edit_request_path(user_not_manager, Date.current) }
      let(:logged_in_employee) { user_manager }
      it_behaves_like "have_http_status_success"
    end
  end
end

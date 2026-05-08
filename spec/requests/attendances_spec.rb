require 'rails_helper'

RSpec.describe "Attendance", type: :request do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_2) { FactoryBot.create(:employee, email: "manager@email", role: :manager) }
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
      expect(response).to redirect_to(employee_attendances_path(logged_in_employee))
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
    describe "GET /index" do
      let(:request_action) { get employee_attendances_path(user_1) }
      it_behaves_like "redirect_to_login_page"
    end

    describe "GET /show" do
      let(:request_action) { get employee_attendance_path(user_1, Date.current) }
      it_behaves_like "redirect_to_login_page"
    end
  end
  context "ユーザー1がログイン時" do
    before do
      sign_in user_1
    end
    describe "GET user_1/attendances/index" do
      let(:request_action) { get employee_attendances_path(employee_id: user_1) }
      let(:logged_in_employee) { user_1 }
      it_behaves_like "have_http_status_success"
    end

    describe "GET user_1/attendances/show" do
      let(:request_action) { get employee_attendance_path(employee_id: user_1, worked_on: Date.today) }
      let(:logged_in_employee) { user_1 }
      it_behaves_like "have_http_status_success"
    end
    describe "GET user_2/attendances/index" do
      let(:request_action) { get employee_attendances_path(employee_id: user_2) }
      let(:logged_in_employee) { user_1 }
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end

    describe "GET user_2/attendances/show" do
      let(:request_action) { get employee_attendance_path(employee_id: user_2, worked_on: Date.today) }
      let(:logged_in_employee) { user_1 }
      it_behaves_like "redirect_to_current_employee_attendance_index_page"
    end
  end

  context "マネージャーがログイン時" do
    before do
      sign_in user_manager
    end
    describe "GET user_1/attendances/index" do
      let(:request_action) { get employee_attendances_path(employee_id: user_1) }
      let(:logged_in_employee) { user_manager }
      it_behaves_like "have_http_status_success"
    end

    describe "GET user_1/attendances/show" do
      let(:request_action) { get employee_attendance_path(employee_id: user_1, worked_on: Date.today) }
      let(:logged_in_employee) { user_manager }
      it_behaves_like "have_http_status_success"
    end
  end
end

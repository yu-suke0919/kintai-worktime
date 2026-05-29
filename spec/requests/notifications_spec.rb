require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let(:user_1) { FactoryBot.create(:employee) }
  let(:user_2) { FactoryBot.create(:employee, email: "user2@email",) }
  let(:user_manager) { FactoryBot.create(:employee, email: "manager@email", role: :manager) }
  before do
    attendance = FactoryBot.create(:attendance, employee: user_1, worked_on: "2026-05-01")
    attendance_edit_request = FactoryBot.create(:attendance_edit_request, attendance: attendance, employee: user_1)
    FactoryBot.create(:notification, recipient_employee: user_1, notifiable: attendance_edit_request)
  end

  shared_examples "have_http_status_success" do
    it "HTTPリクエストステータスが、成功となること" do
      get_action
      expect(response).to have_http_status(:success)
    end
  end

  shared_examples "redirect_to_login_page" do
    it "ログインページにリダイレクトされ、alertが設定されること" do
      get_action
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_employee_session_path)
      expect(flash[:alert]).to be_present
    end
  end

  context "非ログイン時" do
    describe "GET /notifications" do
      let(:get_action) { get notifications_path }
      it_behaves_like "redirect_to_login_page"
    end
  end
  context "ユーザー1がログイン時" do
    before do
      sign_in user_1
    end
    describe "GET /index" do
      let(:get_action) { get notifications_path }
      it_behaves_like "have_http_status_success"
    end

    describe "GET /show" do
      let(:get_action) { get notification_path(user_1.notifications.first) }
      it_behaves_like "have_http_status_success"
    end
  end
end

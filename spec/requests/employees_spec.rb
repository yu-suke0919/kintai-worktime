require 'rails_helper'

RSpec.describe "Employees", type: :request do
  let(:user1) { FactoryBot.create(:employee) }
  shared_examples "redirect_to_login_page" do
    it "ログインページにリダイレクトされ、alertが設定されること" do
      request_action
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_employee_session_path)
      expect(flash[:alert]).to be_present
    end
  end
  shared_examples "have_http_status_success" do
    it "HTTPリクエストステータスが、成功となること"
      request_action
      expect(response).to have_http_status(:success)
    end
  end

  context "非ログイン時" do
    describe "GET /index" do
      let(:request_action) { get employees_path }
      it_behaves_like "redirect_to_login_page"
    end

    describe "GET /show" do
      let(:request_action) { get employee_path(user1) }
      it_behaves_like "redirect_to_login_page"
    end

    describe "GET /new" do
      let(:request_action) { get new_employee_path }
      it_behaves_like "redirect_to_login_page"
    end

    describe "GET /edit" do
      let(:request_action) { get edit_employee_path(user1) }
      it_behaves_like "redirect_to_login_page"
    end
  end
  context "ログイン時" do
    before do
      visit new_employee_session_path
      fill_in 'Email', with: 'test@gmail.com'
      fill_in 'Password', with: '111111'
      click_button 'Log in'
    end
    describe "GET /index" do
      let(:request_action) { get employees_path }
      it_behaves_like "have_http_status_success"
    end

    describe "GET /show" do
      let(:request_action) { get employee_path(user1) }
      it_behaves_like "redirect_to_login_page"
    end

    describe "GET /new" do
      let(:request_action) { get new_employee_path }
      it_behaves_like "redirect_to_login_page"
    end

    describe "GET /edit" do
      let(:request_action) { get edit_employee_path(user1) }
      it_behaves_like "redirect_to_login_page"
    end
  end
end

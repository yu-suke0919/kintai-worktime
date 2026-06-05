require 'rails_helper'

RSpec.describe "Admin::EmployeeWorkDateExceptionRequests", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/employee_work_date_exception_requests/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/employee_work_date_exception_requests/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /approve_request" do
    it "returns http success" do
      get "/admin/employee_work_date_exception_requests/approve_request"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /reject_request" do
    it "returns http success" do
      get "/admin/employee_work_date_exception_requests/reject_request"
      expect(response).to have_http_status(:success)
    end
  end
end

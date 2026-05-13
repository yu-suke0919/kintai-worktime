require 'rails_helper'

RSpec.describe "Admin::AttendanceEditRequests", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/admin/attendance_edit_requests/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/attendance_edit_requests/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/attendance_edit_requests/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /index" do
    it "returns http success" do
      get "/admin/attendance_edit_requests/index"
      expect(response).to have_http_status(:success)
    end
  end

end

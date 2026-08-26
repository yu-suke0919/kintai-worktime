require 'rails_helper'

RSpec.describe "MonthlyAttendanceClosings", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/monthly_attendance_closings/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/monthly_attendance_closings/show"
      expect(response).to have_http_status(:success)
    end
  end
end

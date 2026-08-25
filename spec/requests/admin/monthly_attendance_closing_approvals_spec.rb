require 'rails_helper'

RSpec.describe "Admin::MonthlyAttendanceClosingApprovals", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/monthly_attendance_closing_approvals/index"
      expect(response).to have_http_status(:success)
    end
  end

end

require 'rails_helper'

RSpec.describe "Admin::PaidLeaveGrants", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/paid_leave_grants/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/paid_leave_grants/new"
      expect(response).to have_http_status(:success)
    end
  end

end

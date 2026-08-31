require 'rails_helper'

RSpec.describe "PaidLeaveGrants", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/paid_leave_grants/index"
      expect(response).to have_http_status(:success)
    end
  end

end

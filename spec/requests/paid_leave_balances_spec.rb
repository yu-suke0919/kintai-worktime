require 'rails_helper'

RSpec.describe "PaidLeaveBalances", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/paid_leave_balances/index"
      expect(response).to have_http_status(:success)
    end
  end
end

require 'rails_helper'

RSpec.describe "Admin::Employees", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/employees/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/employees/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/employees/edit"
      expect(response).to have_http_status(:success)
    end
  end

end

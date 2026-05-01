require 'rails_helper'

RSpec.describe "Employees", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/employees/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/employees/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/employees/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/employees/edit"
      expect(response).to have_http_status(:success)
    end
  end

end

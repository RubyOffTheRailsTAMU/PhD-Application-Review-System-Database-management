require 'rails_helper'

RSpec.describe "Uploads", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/uploads/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/uploads/create"
      expect(response).to have_http_status(:success)
    end
  end

end

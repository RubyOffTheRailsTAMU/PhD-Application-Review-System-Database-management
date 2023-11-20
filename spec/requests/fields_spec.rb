require 'rails_helper'

RSpec.describe "Fields", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/fields/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/fields/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/fields/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/fields/edit"
      expect(response).to have_http_status(:success)
    end
  end

end

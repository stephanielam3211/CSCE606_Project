require "rails_helper"

RSpec.describe HomeController, type: :request do
  # 1. Page Load and Status Codes
  describe "GET /" do
    it "returns a successful response" do
      get root_url
      expect(response).to have_http_status(:success)
    end
  end
end
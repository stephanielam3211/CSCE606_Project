require "rails_helper"
RSpec.describe SessionsController, type: :request do
    describe "GET /login" do
      it "renders the login page successfully" do
        get login_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Login")
      end
    end
end
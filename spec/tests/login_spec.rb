# frozen_string_literal: true

require "rails_helper"
RSpec.describe SessionsController, type: :request do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
      provider: 'google',
      uid: '123456789',
      info: { email: 'test@example.com', name: 'Test User' },
      credentials: { token: 'mock_token', refresh_token: 'mock_refresh_token' }
    })
  end

  after { OmniAuth.config.test_mode = false }

  describe "GET /login" do
    it "redirects to the Google OAuth login page" do
      get login_path
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("/auth/google_oauth2")
    end
  end

  describe "POST /login" do
    context "with valid Google OAuth credentials" do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
            provider: 'google',
            uid: '123456789',
            info: { email: 'test@tamu.edu', name: 'Test User' },
            credentials: { token: 'mock_token', refresh_token: 'mock_refresh_token' }
        })
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google]
      end
  
      it "logs in the user and redirects to the home page" do
        get "/auth/google/callback" 
        expect(session[:user_id]).not_to be_nil
        expect(session[:email]).to eq('test@tamu.edu')
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid Google OAuth credentials" do
      it "redirects to the root path with an alert" do
        OmniAuth.config.mock_auth[:google] = :invalid_credentials
        Rails.application.env_config["omniauth.auth"] = nil
        get "/auth/google/callback" 
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "DELETE /logout" do
    before { post login_path, params: { provider: 'google' } }

    it "logs out the user and redirects to the root path" do
      get logout_path
      expect(session.keys - ["session_id", "flash"]).to be_empty
      expect(response).to redirect_to(root_path)
    end

    it "prevents accessing the home page after logout using the back button" do
      get logout_path
      get root_path
      expect(session[:user_id]).to be_nil
      expect(response.body).not_to include("Welcome back")
    end
  end
end

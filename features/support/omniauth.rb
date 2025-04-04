# frozen_string_literal: true

# features/support/omniauth.rb
require 'omniauth'

OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
  provider: 'google_oauth2',
  uid: '1234567890',
  info: {
    name: 'Admin User',
    email: 'admin@tamu.edu'
  },
  credentials: {
    token: 'fake_token',
    refresh_token: 'fake_refresh_token',
    expires_at: Time.now + 1.week
  }
})

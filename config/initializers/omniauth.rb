Rails.application.config.middleware.use OmniAuth::Builder do
    OmniAuth.config.allowed_request_methods = [:post, :get]
    
    provider :google_oauth2,
             ENV['GOOGLE_CLIENT_ID'],
             ENV['GOOGLE_CLIENT_SECRET'],
             scope: 'email,profile',
             prompt: 'select_account',
             redirect_uri: 'https://tamu-ta-ee36b085db2d.herokuapp.com/auth/google/callback'
  end
  
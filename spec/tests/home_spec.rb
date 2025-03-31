# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    it 'responds successfully without requiring login' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end

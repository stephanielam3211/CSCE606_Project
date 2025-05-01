# frozen_string_literal: true

class AdminController < ApplicationController
    before_action :authorize_admin
    def manage_data
    end

    private
    def authorize_admin
        case session[:role].to_s
        when "admin"
        else
          redirect_to root_path, alert: "Unauthorized access."
        end
    end
end

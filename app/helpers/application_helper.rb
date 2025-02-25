# frozen_string_literal: true

module ApplicationHelper
    def toggle_direction
        params[:direction] == "asc" ? "desc" : "asc"
    end
end

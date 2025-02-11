# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_cache_buster

  private

  def set_cache_buster
    response.headers["Cache-Control"] =
"no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end

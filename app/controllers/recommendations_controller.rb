# frozen_string_literal: true

class RecommendationsController < ApplicationController
  def new
    @recommendation = Recommendation.new
  end
  def create
    @recommendation = Recommendation.new(recommendation_params)
    if @recommendation.save
      redirect_to root_path
    else
      render :new
    end
    private
    def recommendation_params
      params.require(:recommendation).permit(:email, :name, :selectionTA, :feedback, :additionalfeedback)
    end
  end
end

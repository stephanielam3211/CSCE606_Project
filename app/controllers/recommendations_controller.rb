# frozen_string_literal: true

class RecommendationsController < ApplicationController
  def index
    @recommendations = Recommendation.all
    respond_to do |format|
      format.html { render plain: "CSV Export Only. Add an HTML view if needed." }
      format.csv { send_data generate_csv, filename: "recommendations.csv" }
    end
  end

  def new
    @recommendation = Recommendation.new
  end

  def create
    @recommendation = Recommendation.new(recommendation_params)
  
    if @recommendation.save
      respond_to do |format|
        format.html { redirect_to new_recommendation_path, notice: "Recommendation submitted successfully!" }
        format.json { render json: { message: "Recommendation submitted successfully!" }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recommendation.errors, status: :unprocessable_entity }
      end
    end
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      csv << ["Timestamp", "Email Address", "Your Name (first and last)", "Select a TA/Grader", "Course (e.g. CSCE 421)", "Feedback", "Additional Feedback about this student"]

      @recommendations.each do |recommendation|
        csv << [
          recommendation.created_at.strftime('%m/%d/%Y %H:%M:%S'),
          recommendation.email,
          recommendation.name,
          recommendation.selectionsTA,
          recommendation.course,
          recommendation.feedback,
          recommendation.additionalfeedback
        ]
      end
    end
  end

  private

  def recommendation_params
    params.require(:recommendation).permit(:email, :name, :selectionsTA,:course, :feedback, :additionalfeedback)
  end
end

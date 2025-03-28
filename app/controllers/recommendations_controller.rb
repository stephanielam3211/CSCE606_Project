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

  def edit
    @recommendation = Recommendation.find(params[:id])
  end

  def update
    @recommendation = Recommendation.find(params[:id])
    if @recommendation.update(recommendation_params)
      redirect_to my_recommendations_view_path, notice: 'Recommendation updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recommendation = Recommendation.find(params[:id])
    @recommendation.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to my_recommendations_view_path, notice: "Course was successfully deleted." }
    end
  end

  def create
    @recommendation = Recommendation.new(recommendation_params)
  
    if @recommendation.save
      respond_to do |format|
        format.html { redirect_to my_recommendations_view_path, notice: "Recommendation submitted successfully!" }
        format.json { render json: { message: "Recommendation submitted successfully!" }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recommendation.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @recommendations = Recommendation.all
  end

  def my_recommendations
    @recommendations = Recommendation.where(email: session[:email])
  end

  def clear
    Recommendation.delete_all
    if request
        redirect_to root_path, notice: "All recommendations have been deleted."
    else
        puts "All recommendations have been deleted."
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
    params.require(:recommendation).permit(:email, :name, :course, :selectionsTA, :feedback, :additionalfeedback)
  end
end

# frozen_string_literal: true

# This controller manages the recommendations functions of the application
class RecommendationsController < ApplicationController
  before_action :authorize_admin!

  def index
    @recommendations = Recommendation.all
    respond_to do |format|
      format.html { render plain: "CSV Export Only. Add an HTML view if needed." }
      format.csv { send_data generate_csv, filename: "recommendations.csv" }
    end
  end

  # This method is used to display the form for creating a new recommendation
  def new
    @recommendation = Recommendation.new
  end

  # This method is used to display the form for editing an existing recommendation
  def edit
    @recommendation = Recommendation.find(params[:id])
  end

  # This method is used to update an existing recommendation
  def update
    @recommendation = Recommendation.find(params[:id])
    if @recommendation.update(recommendation_params)
      redirect_to my_recommendations_view_path, notice: "Recommendation updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # This method is used to delete an existing recommendation
  def destroy
    @recommendation = Recommendation.find(params[:id])
    @recommendation.destroy
    if session[:role].to_s == "admin"
      redirect_to recommendation_view_path, notice: "Recommendation was successfully deleted."
    else
      redirect_to my_recommendations_view_path, notice: "Recommendation was successfully deleted."
    end
  end

  # This method is used to create a new recommendation
  def create
    @recommendation = Recommendation.new(recommendation_params)

    # Check for duplicate (name + course)
    if Recommendation.exists?(name: @recommendation.name, course: @recommendation.course)
      @recommendation.errors.add(:base, "A recommendation already exists for this student and course.")
      render :new, status: :unprocessable_entity and return
    end

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

  # This method is used to display all recommendations
  def show
    @recommendations = Recommendation.all
  end

  # This method is used to display the recommendations made by the logged-in user
  def my_recommendations
    @recommendations = Recommendation.where(email: session[:email])
  end

  # This method is used to clear all recommendations
  def clear
    Recommendation.delete_all
    if request
        redirect_to root_path, notice: "All recommendations have been deleted."
    else
        puts "All recommendations have been deleted."
    end
  end

  private
  def authorize_admin!
    case session[:role].to_s
    when "admin" 
    else
      redirect_to root_path, alert: "Unauthorized access."
    end
  end

  # This method generates a CSV file from the recommendations
  def recommendation_params
    params.require(:recommendation).permit(:email, :name, :course, :selectionsTA, :feedback, :additionalfeedback)
  end
end

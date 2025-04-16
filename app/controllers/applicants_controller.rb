# frozen_string_literal: true

# Used to manage the applicants
class ApplicantsController < ApplicationController
  before_action :set_applicant, only: %i[ show edit update destroy ]
  skip_before_action :require_login, if: -> { Rails.env.test? }

  # GET /applicants or /applicants.json
  def index
    @applicants = Applicant.all
    sort_column = params[:sort] || "name"
    sort_direction = params[:direction] == "desc" ? "desc" : "asc"
    @applicants = Applicant.order("#{sort_column} #{sort_direction}")
    @q = Applicant.ransack(params[:q])
    @applicants = @q.result(distinct: true).order("#{sort_column} #{sort_direction}")
  end

  # Search for applicants by name
  def search
    term = params[:term].to_s.strip.downcase
    applicants = if term.present?
                   Applicant.where("LOWER(name) LIKE ?", "%#{term}%").limit(10)
                 else
                   Applicant.limit(10)
                 end
  
    render json: applicants.map { |applicant| {
      id: applicant.id,
      text: "#{applicant.name} (#{applicant.email})",
      name: applicant.name,
      email: applicant.email,
      degree: applicant.degree,
      uin: applicant.uin,
      number: applicant.number,
      citizenship: applicant.citizenship,
      hours: applicant.hours,
      prev_ta: applicant.prev_ta,
      cert: applicant.cert
    } }
  end

  # Search for applicants by email
  def search_email
    applicants = Applicant.where("email ILIKE ?", "%#{params[:term]}%").limit(10)
    render json: applicants.map { |applicant| {
      id: applicant.id,
      text: "#{applicant.name} (#{applicant.email})",
      name: applicant.name,
      email: applicant.email,
      degree: applicant.degree,
      uin: applicant.uin,
      number: applicant.number,
      citizenship: applicant.citizenship,
      hours: applicant.hours,
      prev_ta: applicant.prev_ta,
      cert: applicant.cert } }
  end

  # Search for applicants by UIN
  def search_uin
    applicants = Applicant.where("uin ILIKE ?", "%#{params[:term]}%").limit(10)
    render json: applicants.map { |applicant| {
      id: applicant.id,
      text: "#{applicant.name} (#{applicant.email})",
      name: applicant.name,
      email: applicant.email,
      degree: applicant.degree,
      uin: applicant.uin,
      number: applicant.number,
      citizenship: applicant.citizenship,
      hours: applicant.hours,
      prev_ta: applicant.prev_ta,
      cert: applicant.cert } }
  end

  # GET /applicants/1 or /applicants/1.json
  def show
  end

  # GET /applicants/new
  def new
    if session[:user_id].present?
      # Check if the user has already submitted an application
      user = User.find(session[:user_id])
      if user.applicant
        redirect_to user.applicant
      else
        @applicant = Applicant.new
        @courses = Course.all.map { |c| "#{c.course_number} - #{c.course_name} (Section: #{c.section})"}
      end
    else
      redirect_to root_path, alert: "Please log in to submit an application."
    end
  
  end




  # GET /applicants/1/edit
  def edit
    @applicant = Applicant.find(params[:id])
    @courses = Course.all.map { |c| "#{c.course_number} - #{c.course_name} (Section: #{c.section})" }
  end

  # POST /applicants or /applicants.json
  def create
    if session[:user_id].present?
      user = User.find(session[:user_id])
      if user.applicant
        redirect_to user.applicant, alert: "You have already submitted an application."
        return
      end
  
      modified_params = applicant_params
      modified_params = modified_params.merge(name: "*#{modified_params[:name]}") if Blacklist.exists?(student_email: modified_params[:email])
  
      @applicant = Applicant.new(modified_params)
      @applicant.confirm = user.id
  
      respond_to do |format|
        if @applicant.save
          format.html { redirect_to @applicant, notice: "Application submitted successfully." }
          format.json { render :show, status: :created, location: @applicant }
        else
          @courses = Course.all.map { |c| "#{c.course_number} - #{c.course_name} (Section: #{c.section})" }
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @applicant.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to root_path, alert: "Please log in to submit an application."
    end
  end

  # PATCH/PUT /applicants/1 or /applicants/1.json
  def update
    respond_to do |format|
      if @applicant.update(applicant_params)
        format.html { redirect_to @applicant, notice: "Applicant was successfully updated." }
        format.json { render :show, status: :ok, location: @applicant }
        flash[:notice] = "Applicant was successfully updated."
      else
        @courses = Course.all.map { |c| "#{c.course_number} - #{c.course_name} (Section: #{c.section})" }
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @applicant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applicants/1 or /applicants/1.json
  def destroy
    @applicant.destroy!

    respond_to do |format|
      format.html {
        if session[:role].to_s == "admin" 
          redirect_to applicants_path,notice: "Applicant was successfully destroyed."
        else 
          redirect_to root_path,notice: "Applicant was successfully destroyed."
        end 
       }
      format.json { head :no_content }
    end
  end
  # Delete all applicants
  def wipe_applicants
    Applicant.delete_all
    redirect_to root_path, notice: "All Applicants have been cleared."
  end

  # for view my application
  def my_application
    # this is a temporary value for debugging need to be fixed after login is finished
    @applicant = Applicant.find_by(email: session[:email])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_applicant
      @applicant = Applicant.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def applicant_params
      params.require(:applicant).permit(:email, :name, :degree, :positions, :gpa,
:number, :uin, :hours, :citizenship, :cert, :prev_course, :prev_uni, :prev_ta, :advisor, :choice_1, :choice_2, :choice_3, :choice_4, :choice_5, :choice_6, :choice_7, :choice_8, :choice_9, :choice_10)
    end
end

# frozen_string_literal: true

class ApplicantsController < ApplicationController
  before_action :set_applicant, only: %i[ show edit update destroy ]

  # GET /applicants or /applicants.json
  def index
    @applicants = Applicant.all
    sort_column = params[:sort] || "name"
    sort_direction = params[:direction] == "desc" ? "desc" : "asc"
    @applicants = Applicant.order("#{sort_column} #{sort_direction}")
    @q = Applicant.ransack(params[:q])
    @applicants = @q.result(distinct: true).order("#{sort_column} #{sort_direction}")
  end

  def search
    applicants = Applicant.where("name LIKE ?", "%#{params[:term]}%").limit(10)
    render json: applicants.map { |applicant| { 
      id: applicant.id, 
      text: "#{applicant.name} (#{applicant.email})",
      name: applicant.name,
      email: applicant.email } }
  end

  # GET /applicants/1 or /applicants/1.json
  def show
  end

  # GET /applicants/new
  def new
    @applicant = Applicant.new
  end

  # GET /applicants/1/edit
  def edit
  end

  # POST /applicants or /applicants.json
  def create
    if Blacklist.exists?(student_email: applicant_params[:email])
      modified_params = applicant_params.merge(name: "*#{applicant_params[:name]}")
    else
      modified_params = applicant_params
    end

    @applicant = Applicant.new(modified_params)

    respond_to do |format|
      if @applicant.save
        format.html {
        redirect_to @applicant, notice: "Applicant was successfully created." }
        format.json { render :show, status: :created, location: @applicant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json {
        render json: @applicant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /applicants/1 or /applicants/1.json
  def update
    respond_to do |format|
      if @applicant.update(applicant_params)
        format.html {
 redirect_to @applicant, notice: "Applicant was successfully updated." }
        format.json { render :show, status: :ok, location: @applicant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json {
 render json: @applicant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applicants/1 or /applicants/1.json
  def destroy
    @applicant.destroy!

    respond_to do |format|
      format.html {
        redirect_to applicants_path, status: :see_other,
        notice: "Applicant was successfully destroyed." }
      format.json { head :no_content }
    end
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
      params.require(:applicant).permit(:email, :name, :degree, :positions,
:number, :uin, :hours, :citizenship, :cert, :prev_course, :prev_uni, :prev_ta, :advisor, :choice_1, :choice_2, :choice_3, :choice_4, :choice_5, :choice_6, :choice_7, :choice_8, :choice_9, :choice_10)
    end

end

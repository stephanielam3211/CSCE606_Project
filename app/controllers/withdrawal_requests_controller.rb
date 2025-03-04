class WithdrawalRequestsController < ApplicationController
    def new
      @withdrawal_request = WithdrawalRequest.new
    end
  
    def create
      @withdrawal_request = WithdrawalRequest.new(withdrawal_request_params)
      if @withdrawal_request.save
        flash[:notice] = "Withdrawal request submitted successfully."
        redirect_to root_path
      else
        flash[:alert] = "There was an error submitting your request."
        render :new
      end
    end

    def index
        @withdrawal_requests = WithdrawalRequest.all
    end
  
    private
  
    def withdrawal_request_params
      params.require(:withdrawal_request).permit(:course_number, :section_id, :instructor_name, :instructor_email, :student_name, :student_email)
    end
end
  
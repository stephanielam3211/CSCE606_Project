class UnassignedApplicantsController < ApplicationController
    def search
        applicants = UnassignedApplicant.where("name LIKE ?", "%#{params[:term]}%").limit(10)
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
      
      def search_email
        applicants = Applicant.where("email LIKE ?", "%#{params[:term]}%").limit(10)
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
      
      def search_uin
        applicants = Applicant.where("uin LIKE ?", "%#{params[:term]}%").limit(10)
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
end

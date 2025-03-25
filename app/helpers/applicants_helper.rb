# frozen_string_literal: true

module ApplicantsHelper
    def from_my_application?
        params[:from] == "my_application"
      end
end

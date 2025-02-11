# frozen_string_literal: true

json.array! @applicants, partial: "applicants/applicant", as: :applicant

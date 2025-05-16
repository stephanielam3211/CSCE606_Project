# frozen_string_literal: true

module RecommendationsHelper
  def recommendation_class(feedback)
    case feedback
    when "I want to work with this student"
        "yes-recommendation"
    when "I would recommend this person as a good TA/grader"
        "ok-recommendation"
    when "I would not recommend this student"
        "bad-recommendation"
    else
        "no-recommendation"
    end
  end
end

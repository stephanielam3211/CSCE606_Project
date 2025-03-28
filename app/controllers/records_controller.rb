# frozen_string_literal: true

class RecordsController < ApplicationController
  def index
    @table_name = params[:table]
    case @table_name
    when "grader_matches"
      @records = GraderMatch.all
    when "recommendations"
      @records = Recommendation.all
    when "senior_grader_matches"
      @records = SeniorGraderMatch.all
    when "ta_matches"
      @records = TaMatch.all
    else
      @records = []
    end
  end
end

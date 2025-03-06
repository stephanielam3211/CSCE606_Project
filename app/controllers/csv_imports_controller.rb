class CsvImportsController < ApplicationController
    def import
      system("rake import:csv")
  
      flash[:notice] = "CSV import started!"
      redirect_back fallback_location: root_path
    end
  end
class TaAssignmentsController < ApplicationController
  require 'csv'
  def process_csvs
    if params[:file1].present? && params[:file2].present? && params[:file3].present?
      file1_path = save_uploaded_file(params[:file1])
      file2_path = save_uploaded_file(params[:file2])
      file3_path = save_uploaded_file(params[:file3])

      system("python3 app/Charizard/main.py #{file1_path} #{file2_path} #{file3_path}")

      flash[:notice] = "CSV processing complete"
      redirect_to view_csv_path
    else
      flash[:alert] = "Please upload all 3 CSV files."
      redirect_to ta_assignments_new_path
    end
  end

  def view_csv
    csv_directory = Rails.root.join('app', 'Charizard', 'output')
    @csv_files = Dir.entries(csv_directory).select { |f| f.end_with?('.csv') }
    
    if params[:file].present? && @csv_files.include?(params[:file])
      @selected_csv = params[:file]
      @csv_content = read_csv(File.join(csv_directory, @selected_csv))
    end
  end
  def download_csv
    file_name = params[:file]
    file_path = Rails.root.join('app', 'Charizard', 'output', file_name)
    if File.exist?(file_path)
      send_file file_path, filename: file_name, type: 'text/csv', disposition: 'attachment'
    else
      redirect_to root_path, alert: "File not found."
    end
  end

  private
  def save_uploaded_file(file)
    path = Rails.root.join('tmp', file.original_filename)
    File.open(path, 'wb') { |f| f.write(file.read) }
    path
  end

  def read_csv(file_path)
    csv_data = []
    CSV.foreach(file_path, headers: true) do |row|
      csv_data << row.to_h
    end
    csv_data
  end
end

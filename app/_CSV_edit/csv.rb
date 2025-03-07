require 'csv'

module CsvFilter
  def self.remove_matching_emails(input_csv, exclusion_csv, output_csv)
    exclusion_emails = CSV.read(exclusion_csv, headers: true).map { |row| row['email'] }.compact

    filtered_rows = []
    headers = nil

    CSV.foreach(input_csv, headers: true) do |row|
      headers ||= row.headers # Save headers for output
      filtered_rows << row unless exclusion_emails.include?(row['email'])
    end

    CSV.open(output_csv, 'w') do |csv|
      csv << headers
      filtered_rows.each { |row| csv << row }
    end

    puts "Filtered CSV saved as #{output_csv}"
  end
end

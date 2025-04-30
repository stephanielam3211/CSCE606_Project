require Rails.root.join('lib/s3_downloader').to_s

Rails.application.config.to_prepare do
  if (Rails.env.production? || Rails.env.staging?) && ENV['BUCKETEER_AWS_REGION'].present?
    puts "Downloading CSV files from S3..."

    directory_path = Rails.root.join("tmp/s3_output")

    downloader = S3Downloader.new(
      bucket_name: ENV['BUCKETEER_BUCKET_NAME'],
      directory_path: directory_path
    )

    begin
      downloader.download_files
    rescue => e
      Rails.logger.error "S3 download failed: #{e.message}"
    end
  else
    puts "Skipping S3 download – AWS_REGION not set or wrong environment."
  end
end
# frozen_string_literal: true
Rails.application.config.to_prepare do
  if (Rails.env.production? || Rails.env.staging?) && ENV['BUCKETEER_AWS_REGION'].present?
    puts "Downloading CSV files from S3..."

    downloader = S3Downloader.new(
      bucket_name: ENV['BUCKETEER_BUCKET_NAME']
    )
    downloader.download_files
  else
    puts "Skipping S3 download – AWS_REGION not set or wrong environment."
  end
end
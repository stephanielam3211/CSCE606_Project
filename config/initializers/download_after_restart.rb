require Rails.root.join('lib/s3_downloader')

Rails.application.config.to_prepare do
    if (Rails.env.production? || Rails.env.staging?) && ENV['BUCKETEER_AWS_REGION'].present?
      puts "Downloading CSV files from S3..."
  
      directory_path = Rails.root.join("app/Charizard/util/public/output")
  
      downloader = S3Downloader.new(
        bucket_name: ENV['BUCKETEER_BUCKET_NAME'],
        directory_path: directory_path
      )
      downloader.download_files
    else
      puts "Skipping S3 download – AWS_REGION not set or wrong environment."
    end
  end

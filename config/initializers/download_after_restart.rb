
Rails.application.config.after_initialize do
    if Rails.env.production? || Rails.env.staging?
      puts "Downloading CSV files from S3..."
  
      # Specify the directory to save files locally
      directory_path = Rails.root.join("app/Charizard/util/public/output")
  
      # Create the downloader and trigger download
      downloader = S3FileDownloader.new(
        bucket_name: ENV['BUCKETEER_BUCKET_NAME'],
        directory_path: directory_path
      )
      downloader.download_files
    end
end

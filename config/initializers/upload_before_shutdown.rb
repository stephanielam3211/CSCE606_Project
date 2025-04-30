require 'aws-sdk-s3'
require 'fileutils'

at_exit do
  # Check if this is a dyno restart or shutdown
  if Rails.env.production? || Rails.env.staging?
    puts "Application is shutting down. Uploading files to S3..."
        
    # Path to the directory where your CSV files are stored
    directory_path = Rails.root.join("app/Charizard/util/public/output")
        
    # Call method to upload the CSV files to S3
    upload_all_files_to_s3(directory_path)
  end
end

def upload_all_files_to_s3(directory_path)
  s3 = Aws::S3::Client.new(
    region: ENV['BUCKETEER_AWS_REGION'],
    access_key_id: ENV['BUCKETEER_AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['BUCKETEER_AWS_SECRET_ACCESS_KEY']
  )
  bucket = ENV['BUCKETEER_BUCKET_NAME']

  Dir.glob("#{directory_path}/**/*.csv") do |file_path|
    next unless File.exist?(file_path)

    # Create the S3 key (path on S3)
    s3_key = "csv/#{File.basename(file_path)}"

    # Check if the file exists in S3
    existing_object = s3.head_object(bucket: bucket, key: s3_key) rescue nil

    # Upload the file only if it doesn't exist, or the local file is newer
    if existing_object.nil? || File.mtime(file_path) > Time.parse(existing_object.last_modified.to_s)
      File.open(file_path, 'rb') do |file|
        s3.put_object(bucket: bucket, key: s3_key, body: file)
      end
      puts "Uploaded #{file_path} to S3 as #{s3_key}"
    else
      puts "Skipping #{file_path} (S3 file is up-to-date)"
    end
  end
end
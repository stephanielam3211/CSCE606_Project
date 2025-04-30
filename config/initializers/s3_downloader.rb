require 'aws-sdk-s3'
require 'fileutils'

class S3Downloader
  def initialize(bucket_name:)
    @bucket_name = bucket_name
    @s3_client = Aws::S3::Client.new(region: ENV['BUCKETEER_AWS_REGION'])
  end

  def download_files
    s3 = Aws::S3::Resource.new(client: @s3_client)
    bucket = s3.bucket(@bucket_name)

    bucket.objects.each do |obj|
      # Build the directory path dynamically using the key
      directory_path = Rails.root.join('app', 'Charizard', 'util', 'public', 'output')
      filename = File.join(directory_path, File.basename(obj.key)) # Use the object's key here

      puts "Downloading: #{obj.key} -> #{filename}"  # 🔹 Add log here
      FileUtils.mkdir_p(File.dirname(filename))  # Ensure the directory exists
      obj.get(response_target: filename)  # Download the file
    rescue => e
      puts "Failed to download #{obj.key}: #{e.message}"  # 🔹 Log errors too
    end
  end
end
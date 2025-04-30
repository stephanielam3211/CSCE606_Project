require 'aws-sdk-s3'
require 'fileutils'

class S3Downloader
  def initialize(bucket_name:)
    @bucket_name = bucket_name
    @directory_path = Rails.root.join('app', 'Charizard', 'util', 'public', 'output', File.basename(key)) 
    @s3_client = Aws::S3::Client.new(
      region: ENV['BUCKETEER_AWS_REGION'],
    )
  end

  def download_files
    s3 = Aws::S3::Resource.new(client: @s3_client)
    bucket = s3.bucket(@bucket_name)
  

    bucket.objects.each do |obj|
      filename = File.join(@directory_path, obj.key)
      puts "Downloading: #{obj.key} -> #{filename}"  # 🔹 Add log here
      FileUtils.mkdir_p(File.dirname(filename))
      obj.get(response_target: filename)
    rescue => e
      puts "Failed to download #{obj.key}: #{e.message}"  # 🔹 Log errors too
    end
  end
end

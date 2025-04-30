require 'aws-sdk-s3'
require 'fileutils'
# This sets up the method for file downloads from s3 aws
class S3Downloader
  def initialize(bucket_name:)
    @bucket_name = bucket_name
    @s3_client = Aws::S3::Client.new(region: ENV['BUCKETEER_AWS_REGION'])
  end

  def download_files
    s3 = Aws::S3::Resource.new(client: @s3_client)
    bucket = s3.bucket(@bucket_name)

    bucket.objects.each do |obj|
      directory_path = Rails.root.join('app', 'Charizard', 'util', 'public', 'output')
      filename = File.join(directory_path, File.basename(obj.key))

      puts "Downloading: #{obj.key} -> #{filename}"
      FileUtils.mkdir_p(File.dirname(filename))
      obj.get(response_target: filename)
    rescue => e
      puts "Failed to download #{obj.key}: #{e.message}" 
    end
  end
end
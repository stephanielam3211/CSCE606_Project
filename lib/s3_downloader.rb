require 'aws-sdk-s3'

require Rails.root.join('lib/s3_downloader')

class S3FileDownloader
  def initialize(bucket_name:, directory_path:)
    @bucket_name = bucket_name
    @directory_path = directory_path
    @s3_client = Aws::S3::Client.new(
      region: ENV['BUCKETEER_AWS_REGION'],
    )
  end

  def download_files
    s3 = Aws::S3::Resource.new(client: @s3_client)
    bucket = s3.bucket(@bucket_name)

    bucket.objects.each do |obj|
      filename = File.join(@directory_path, obj.key)
      FileUtils.mkdir_p(File.dirname(filename))
      obj.get(response_target: filename)
    end
  end
end
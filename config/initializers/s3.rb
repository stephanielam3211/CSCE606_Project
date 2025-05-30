if ENV['RACK_ENV'] == 'production'
  require 'aws-sdk-s3'

  Aws.config.update({
    region: ENV['BUCKETEER_AWS_REGION'] || 'us-east-1',
    credentials: Aws::Credentials.new(
      ENV['BUCKETEER_AWS_ACCESS_KEY_ID'],
      ENV['BUCKETEER_AWS_SECRET_ACCESS_KEY']
    )
  })

  S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['BUCKETEER_BUCKET_NAME'])
else
  S3_BUCKET = nil
end
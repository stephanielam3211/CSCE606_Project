# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TaAssignmentApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.before_configuration do
      if (Rails.env.production? || Rails.env.staging?) && ENV['BUCKETEER_AWS_REGION'].present?
        require Rails.root.join('lib/s3_downloader')

        Rails.logger.info "Downloading CSV files from S3 (early boot)..."

        directory_path = Rails.root.join("app/Charizard/util/public/output")
        FileUtils.mkdir_p(directory_path)

        downloader = S3Downloader.new(
          bucket_name: ENV['BUCKETEER_BUCKET_NAME'],
          directory_path: directory_path
        )
        downloader.download_files
      end
    end
  end
end

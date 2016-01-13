require 'aws-sdk'

Aws.add_service(:MeteringService, api: File.expand_path('../api-2.json', __FILE__))
Aws.eager_autoload!(services: %w(MeteringService))

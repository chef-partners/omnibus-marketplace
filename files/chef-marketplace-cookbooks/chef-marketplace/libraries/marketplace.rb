## Copyright:: Copyright (c) 2015 Chef Software, Inc.
## License:: Apache License, Version 2.0
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

require 'mixlib/config'
require 'chef/mash'

module Marketplace
  extend Mixlib::Config

  config_context :motd do
    default :enabled, true
  end

  config_context :support do
    default :email, 'aws@chef.io'
  end

  config_context :documentation do
    default :url, 'https://docs.chef.io/aws_marketplace.html'
  end

  default :api_fqdn, nil

  default :license_count, 5

  # Which role the marketplace addition is to play, eg: 'server', 'aio', 'analytics'
  default :role, 'server'

  # The marketplace platform, eg: 'aws', 'openstack', 'azure', 'gce', etc.
  default :platform, 'aws'

  default :user, 'ec2-user'

  # Set to true if you don't want to use outbound networks, eg: package mirrors
  default :disable_outboud_traffic, false

  config_context :publishing do
    # Prep the node for publishing
    default :enabled, false
  end

  config_context :security do
    # Force enable or disable the security recipe
    default :enabled, false
  end

  config_context :reporting do
    config_context :cron do
      default :enabled, true

      # Standard crontab expression
      default :expression, '*/1 * * * *'

      # Up to what year to delete, must be a valid shell command
      default :year, 'date +%Y'

      # Up to what month to delete, must be a valid shell command
      default :month, 'date +%m'
    end
  end

  config_context :analytics do
    default :ssl_port, 8443
  end
end

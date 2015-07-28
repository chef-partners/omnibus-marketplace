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

  # Which role the marketplace addition is to play, eg: 'server' or 'analytics'
  role 'server'

  # The marketplace platform
  platform 'aws'

  config_context :publishing do
    # Prep the node for marketplace publishing, eg: run the security recipes
    default :enabled, false
  end
end

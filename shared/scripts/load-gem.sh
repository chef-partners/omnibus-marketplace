#!/bin/bash

/opt/chef-marketplace/embedded/bin/gem \
  install /sync/chef-marketplace-gem/chef-marketplace-*.gem \
  --without development
/opt/chef-marketplace/embedded/bin/gem \
  install /sync/chef-marketplace-gem/chef-marketplace-*.gem \
  -i /opt/chef-marketplace/embedded/service/gem/ruby/2.2.0 \
  --without development

echo "Workstation version of 'chef-marketplace-gem' loaded"

#!/bin/bash

if ! [ -L /opt/chef-marketplace/embedded/cookbooks/chef-marketplace ]; then
  mv /opt/chef-marketplace/embedded/cookbooks/chef-marketplace /opt/chef-marketplace/embedded/cookbooks/chef-marketplace-pristine
  ln -s /sync/marketplace-cookbooks/chef-marketplace/ /opt/chef-marketplace/embedded/cookbooks/chef-marketplace
fi

rm -rf /var/opt/chef-marketplace/embedded/cookbooks/cache/*

echo "Workstation version of 'chef-marketplace' cookbook loaded"

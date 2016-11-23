#!/bin/bash

if ! [ -L /opt/chef-marketplace/embedded/service/chef-marketplace-ctl ]; then
  mv /opt/chef-marketplace/embedded/service/chef-marketplace-ctl /opt/delivery/embedded/service/chef-marketplace-ctl-pristine
  ln -s /sync/ctl-commands /opt/chef-marketplace/embedded/service/chef-marketplace-ctl
fi

echo "Workstation version of 'chef-marketplace-ctl' files loaded"

#!/bin/bash

if ! [ -L /opt/chef-marketplace/embedded/service/reckoner ]; then
  mv /opt/chef-marketplace/embedded/service/reckoner /opt/chef-marketplace/embedded/service/reckoner-pristine
  ln -s /sync/reckoner /opt/chef-marketplace/embedded/service/reckoner
fi

# Make sure the bundle config points to the embedded service gems
mkdir -p /opt/chef-marketplace/embedded/service/reckoner/.bundle
cat <<EOF > /opt/chef-marketplace/embedded/service/reckoner/.bundle/config
---
BUNDLE_PATH: "/opt/chef-marketplace/embedded/service/gem"
BUNDLE_DISABLE_SHARED_GEMS: trueA
EOF

echo "Workstation version of 'reckoner' loaded"

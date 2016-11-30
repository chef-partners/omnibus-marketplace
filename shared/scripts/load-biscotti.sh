#!/bin/bash

if ! [ -L /opt/chef-marketplace/embedded/service/biscotti ]; then
  mv /opt/chef-marketplace/embedded/service/biscotti /opt/chef-marketplace/embedded/service/biscotti-pristine
  ln -s /sync/biscotti /opt/chef-marketplace/embedded/service/biscotti
fi

# Make sure the bundle config points to the embedded service gems
mkdir -p /opt/chef-marketplace/embedded/service/biscotti/.bundle
cat <<EOF > /opt/chef-marketplace/embedded/service/biscotti/.bundle/config
---
BUNDLE_PATH: "/opt/chef-marketplace/embedded/service/gem"
BUNDLE_DISABLE_SHARED_GEMS: trueA
EOF

echo "Workstation version of 'biscotti' loaded"

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
BUNDLE_DISABLE_SHARED_GEMS: true
EOF

apt-get install -y build-essential
CPPFLAGS="-I/opt/chef-marketplace/embedded/include -O2" \
CXXFLAGS="-I/opt/chef-marketplace/embedded/include -O2" \
CFLAGS="-I/opt/chef-marketplace/embedded/include -O2" \
LDFLAGS="-Wl,-rpath,/opt/chef-marketplace/embedded/lib -L/opt/chef-marketplace/embedded/lib" \
LD_RUN_PATH="/opt/chef-marketplace/embedded/lib" \
PATH="/opt/chef-marketplace/bin:/opt/chef-marketplace/embedded/bin:$PATH" \
PKG_CONFIG_PATH="/opt/chef-marketplace/embedded/lib/pkgconfig" && \
cd /opt/chef-marketplace/embedded/service/reckoner && \
/opt/chef-marketplace/embedded/bin/ruby /opt/chef-marketplace/embedded/bin/bundle install --path /opt/chef-marketplace/embedded/service/gem

echo "Workstation version of 'reckoner' loaded"

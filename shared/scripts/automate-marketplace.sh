#!/bin/bash

export CHANNEL=${CHANNEL:-current}
export VERSION=${VERSION:-latest}
export U_CHANNEL=${U_CHANNEL:-no_upgrade}
export U_VERSION=${U_VERSION:-latest}
export CA_CHANNEL=${CA_CHANNEL:-stable}
export CS_CHANNEL=${CS_CHANNEL:-stable}

# Clean up old target
if [ -f /shared/targets/${HOSTNAME} ]; then
  rm /shared/targets/${HOSTNAME}
fi

# Test and make sure we have access to artifactory.chef.co
test_artifactory=$(curl --output /dev/null --insecure --silent --head artifactory.chef.co)
exit_status=$?

if [ "$exit_status" -ne "0" ]; then
  echo
  echo "Could not connect to artifactory.chef.co to download packages and versions metadata"
  echo
  exit 1
fi

# Install build essential cause we'll probably need to compile gem extensions
apt-get update
dpkg -l | grep build-essential || (apt-get install --no-install-recommends -y build-essential)

# Route ec2-metadata requests to the fake metadata service.
metadata_ip=`getent hosts ec2-metadata | awk '{ print $1 }'`
if [ ! -z ${metadata_ip} ]; then
  dpkg -l | grep iptables || (apt-get install --no-install-recommends -y iptables)
  sysctl -w net.ipv4.conf.eth0.route_localnet=1
  iptables -t nat -p tcp -A OUTPUT -d 169.254.169.254 -j DNAT --to-destination ${metadata_ip}:9666
fi

# Please chef-server-ctl's preflight checks
sysctl -w net.ipv6.conf.lo.disable_ipv6=0

# Make chef-client think we're in ec2
mkdir -p /etc/chef/ohai/hints
touch /etc/chef/ohai/hints/ec2.json

# Install Marketplace, Automate and Chef Server
echo "Install Chef Marketplace ${VERSION} from the ${CHANNEL} channel"
/opt/chefdk/bin/chef-apply /shared/recipes/marketplace-install.rb

export PATH=/opt/chef-marketplace/bin:/opt/delivery/bin:/opt/opscode/bin:$PATH

# Start this so that delivery-ctl, chef-server-ctl, and marketplace-ctl
# sv-related commands can interact with its services via runsv
/opt/delivery/embedded/bin/runsvdir-start &
/opt/opscode/embedded/bin/runsvdir-start &
/opt/chef-marketplace/embedded/bin/runsvdir-start &

/opt/chefdk/bin/chef-apply /shared/recipes/setup-marketplace.rb

# Upgrade Marketplace
if [ "$U_CHANNEL" != "no_upgrade" ]; then
  echo "Upgrade to Marketplace ${U_VERSION} from the ${U_CHANNEL} channel"
  export CHANNEL=${U_CHANNEL}
  export VERSION=${U_VERSION}
  /opt/chefdk/bin/chef-apply /shared/recipes/marketplace-install.rb
  /opt/chefdk/bin/chef-apply /shared/recipes/setup-marketplace.rb
fi

if [ -f /var/opt/chef-marketplace/preconfigured ]; then
  /opt/chefdk/bin/chef-apply /shared/recipes/setup-automate.rb
  /opt/chefdk/bin/chef-apply /shared/recipes/setup-chef-server.rb
else
  chef-marketplace-ctl setup --preconfigure
  touch /var/opt/chef-marketplace/preconfigured
fi

# Setup chef-client-test
/opt/chefdk/bin/chef-apply /shared/recipes/setup-chef-client-test.rb

# Something useful that also keeps the container running...
chef-marketplace-ctl tail

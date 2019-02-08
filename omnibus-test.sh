#!/bin/bash
set -ueo pipefail

channel="${CHANNEL:-unstable}"
product=marketplace
version="${VERSION:-latest}"
dep_channel="${DEP_CHANNEL:-current}"

create_license_guard_file() {
  SERVER_INSTALL_DIR="$1"

  echo "Creating license acceptance guard file"
  sudo mkdir -p "/var/opt/$(basename $SERVER_INSTALL_DIR)"
  sudo touch "/var/opt/$(basename $SERVER_INSTALL_DIR)/.license.accepted"
}

echo "--- Installing $dep_channel chef-server latest"
install-omnibus-product -c "$dep_channel" -P chef-server -v latest

echo "--- Installing $channel $product $version"
package_file="$(install-omnibus-product -c "$channel" -P "$product" -v "$version" | tail -n 1)"

if [[ "$package_file" == *.rpm ]]; then
  check-rpm-signed "$package_file"
fi

echo "--- Testing $channel $product $version"

export PATH="/opt/chef-marketplace/bin:/opt/chef-marketplace/embedded/bin:$PATH"
export INSTALL_DIR="/opt/chef-marketplace"

echo ""
echo ""
echo "============================================================"
echo "Verifying ownership of package files"
echo "============================================================"
echo ""

NONROOT_FILES="$(find "$INSTALL_DIR" ! -uid 0 -print)"
if [[ "$NONROOT_FILES" == "" ]]; then
  echo "Packages files are owned by root.  Continuing verification."
else
  echo "Exiting with an error because the following files are not owned by root:"
  echo "$NONROOT_FILES"
  exit 1
fi

echo ""
echo ""
echo "============================================================"
echo "Reconfiguring $product"
echo "============================================================"
echo ""

sudo chef-server-ctl reconfigure
sleep 120

create_license_guard_file /opt/chef-marketplace || true
sudo chef-marketplace-ctl reconfigure || true
sleep 120

echo ""
echo ""
echo "============================================================"
echo "Running verification for $product"
echo "============================================================"
echo ""

sudo rm -rf /{etc,var/opt}/opscode-{manage,reporting} && sudo chef-marketplace-ctl test

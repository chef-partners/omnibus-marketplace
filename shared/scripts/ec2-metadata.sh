#!/bin/bash -ex

export PATH=/opt/chefdk/embedded/bin:$PATH
gem install sinatra

cat << 'EOS' | tee /usr/src/ec2-metadata.rb
#!/usr/bin/env ruby

require "sinatra"

set :port, 9666
set :bind, "0.0.0.0"

# Ohai will see this and use /latest for the metadata version
get "/" do
  status 404
end

{
  "hostname" => "automate-marketplace",
  "instance-id" => "i-2792638",
  "local-hostname" => "automate-marketplace",
  "local-ipv4" => "172.16.238.33",
  "product-codes" => "ed3lb0p2oc2ot3v9v72ku1pdt",
  "public-hostname" => "automate-marketplace.test",
  "public-ipv4" => "172.16.238.33",
}.each_pair do |route, value|
  get "/latest/meta-data/#{route}/?" do
    value
  end
end

get "/latest/meta-data/" do
  %w(hostname instance-id local-hostname local-ipv4 product-codes public-hostname public-ipv4).join("\n")
end
EOS

ruby /usr/src/ec2-metadata.rb

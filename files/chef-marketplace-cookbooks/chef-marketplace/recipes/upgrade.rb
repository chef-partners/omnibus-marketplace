include_recipe "chef-marketplace::config"

unless mirrors_reachable?
  Chef::Log.warn "Skipping package upgrade because mirrors are not available or outboud traffic is disabled..."
  return
end

node["chef-marketplace"]["upgrade_packages"].each do |pkg|
  include_recipe "chef-marketplace::_upgrade_#{pkg.tr('-', '_')}"
end

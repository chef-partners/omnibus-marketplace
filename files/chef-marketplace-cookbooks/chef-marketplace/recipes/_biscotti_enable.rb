biscotti_config_dir = "/var/opt/chef-marketplace/biscotti/etc"
biscotti_log_dir = "/var/log/chef-marketplace/biscotti"
biscotti_app_config = ::File.join(biscotti_config_dir, "config.yml")
bisoctti_unicorn_config = ::File.join(biscotti_config_dir, "unicorn.rb")

nginx_addon_dir = node["chef-marketplace"]["biscotti"]["nginx"]["add_on_dir"]
nginx_scripts_dir = node["chef-marketplace"]["biscotti"]["nginx"]["scripts_dir"]
nginx_sha1_lua = ::File.join(nginx_scripts_dir, "sha1.lua")
nginx_biscotti_lua = node["chef-marketplace"]["biscotti"]["nginx"]["biscotti_lua_file"]
nginx_biscotti_upstream = ::File.join(nginx_addon_dir, "25-biscotti_upstreams.conf")
nginx_biscotti_external = if node["chef-marketplace"]["role"] == "automate"
                            # automate loads all of the routes from *_internal
                            ::File.join(nginx_addon_dir, "25-biscotti_internal.conf")
                          else
                            ::File.join(nginx_addon_dir, "25-biscotti_external.conf")
                          end

# HACK: Right now the the chef server nginx template doesn't allow us to
# specify a file location for access_by_lua_file so we're manually hacking that
# file on disk.  We can remove these next two resources these changes have been
# merged upstream.
server_lb_template = "/opt/opscode/embedded/cookbooks/private-chef/templates/default/nginx/nginx_chef_api_lb.conf.erb"

directory ::File.dirname(server_lb_template) do
  owner "root"
  group "root"
  mode "0644"
  recursive true
  action :create
  only_if { node["chef-marketplace"]["role"] =~ /aio|server/ }
end

cookbook_file server_lb_template do
  source "chef_server_nginx_lb.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  only_if { node["chef-marketplace"]["role"] =~ /aio|server/ }
end

# Ensure these directories exist but do not manage their mode, let Chef Server
# or Chef Compliance do that.
[nginx_addon_dir, nginx_scripts_dir].each do |dir|
  directory dir do
    recursive true
    action :create
  end
end

template nginx_biscotti_lua do
  source "biscotti.lua.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(token_hmac: biscotti_token_hmac)
end

template nginx_biscotti_upstream do
  source "biscotti_nginx_upstreams.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

template nginx_biscotti_external do
  source "biscotti_nginx_external.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

directory biscotti_config_dir do
  owner "opscode"
  group "opscode"
  mode "0775"
  recursive true
  action :create
end

file biscotti_app_config do
  content biscotti_yml_config
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "runit_service[biscotti]"
  action :create
end

template bisoctti_unicorn_config do
  source "biscotti_unicorn.rb.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "runit_service[biscotti]"
  action :create
end

link "/opt/chef-marketplace/embedded/service/biscotti/config/config.yml" do
  to biscotti_app_config
end

directory biscotti_log_dir do
  owner "root"
  group "root"
  mode "0775"
  recursive true
  action :create
end

component_runit_service "biscotti" do
  package "chef-marketplace"
end

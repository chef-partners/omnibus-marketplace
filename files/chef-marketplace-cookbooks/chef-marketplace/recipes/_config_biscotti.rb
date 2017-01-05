case node['chef-marketplace']['role']
when 'aio', 'server'
  node.default['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/opscode/nginx'
  node.default['chef-marketplace']['biscotti']['redirect_path'] = '/biscotti/'
  node.default['chef-marketplace']['automate']['credentials'] = {}
when 'automate'
  node.default['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/delivery/nginx'
  node.default['chef-marketplace']['biscotti']['redirect_path'] = '/biscotti/setup'
  node.default['chef-marketplace']['automate']['credentials'] = {
    'admin_password' => node['chef-marketplace']['automate']['passwords']['admin_user'],
    'builder_password' => node['chef-marketplace']['automate']['passwords']['builder_user']
  }
when 'compliance'
  node.default['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/chef-compliance/nginx'
  node.default['chef-marketplace']['biscotti']['redirect_path'] = '/biscotti/'
  node.default['chef-marketplace']['automate']['credentials'] = {}
end

uuid_type, uuid =
  case node['chef-marketplace']['platform']
  when 'google'
    ['Project Name', node.gce.project.projectId]
  when 'azure'
    ['VM Name', node.hostname]
  else # aws, testing
    ['Instance ID', node.ec2.instance_id]
  end

node.default['chef-marketplace']['biscotti']['nginx']['add_on_dir'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['dir'], 'etc', 'addon.d')
node.default['chef-marketplace']['biscotti']['nginx']['scripts_dir'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['dir'], 'etc', 'scripts')
node.default['chef-marketplace']['biscotti']['nginx']['biscotti_lua_file'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['scripts_dir'], 'biscotti.lua')
node.default['chef-marketplace']['biscotti']['uuid_type'] = uuid_type
node.default['chef-marketplace']['biscotti']['uuid'] = uuid
node.default['chef-marketplace']['biscotti']['message'] =
  "Please enter your #{uuid_type} to continue to the web interface"

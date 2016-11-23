case node['chef-marketplace']['role']
when 'aio', 'server'
  node.set['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/opscode/nginx'
when 'automate'
  node.set['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/delivery/nginx'
when 'compliance'
  node.set['chef-marketplace']['biscotti']['nginx']['dir'] = '/var/opt/chef-compliance/nginx'
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

node.set['chef-marketplace']['biscotti']['nginx']['add_on_dir'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['dir'], 'etc', 'addon.d')
node.set['chef-marketplace']['biscotti']['nginx']['scripts_dir'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['dir'], 'etc', 'scripts')
node.set['chef-marketplace']['biscotti']['nginx']['biscotti_lua_file'] =
  ::File.join(node['chef-marketplace']['biscotti']['nginx']['scripts_dir'], 'biscotti.lua')
node.set['chef-marketplace']['biscotti']['uuid_type'] = uuid_type
node.set['chef-marketplace']['biscotti']['uuid'] = uuid
node.set['chef-marketplace']['biscotti']['message'] =
  "Please enter your #{uuid_type} to continue to the web interface"

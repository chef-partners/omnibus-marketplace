motd '50-chef-marketplace-appliance' do
  source 'motd.erb'
  cookbook 'chef-marketplace'
  variables(
    role: 'analytics',
    support_email: node['chef-marketplace']['support']['email'],
    doc_url: node['chef-marketplace']['documentation']['url']
  )
  action motd_action
end

gen_api_fqdn = lambda do
  if File.exist?('/etc/chef-marketplace/chef-marketplace-running.json')
    marketplace = JSON.parse(IO.read('/etc/chef-marketplace/chef-marketplace-running.json'))['chef-marketplace']

    api_fqdn marketplace['api_fqdn']
    license['nodes'] = marketplace['license_count']

    if marketplace['role'] == 'aio'
      redirect_uri = "https://#{marketplace['api_fqdn']}:#{marketplace['analytics']['ssl_port']}"
      oc_id['applications'] = { 'analytics' => { 'redirect_uri' => redirect_uri } }
    end
  end

  topology 'standalone'
  gen_api_fqdn_default
end

PrivateChef.register_extension('chef-marketplace', server_config_required: false, gen_api_fqdn: gen_api_fqdn)

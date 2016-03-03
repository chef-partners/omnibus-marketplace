secrets_file = '/etc/chef-marketplace/chef-marketplace-secrets.json'
secrets =
  if ::File.exist?(secrets_file)
    Chef::JSONCompat.from_json(::File.read(secrets_file))
  else
    new_secrets = {
      'biscotti' => {
        'token' => SecureRandom.hex(50)
      }
    }

    file secrets_file do
      content Chef::JSONCompat.to_json_pretty(new_secrets)
      sensitive true
      action :create
    end

    new_secrets
  end

node.consume_attributes('chef-marketplace' => secrets)

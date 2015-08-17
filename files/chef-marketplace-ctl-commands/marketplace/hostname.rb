require 'ohai'

class Marketplace
  class Hostname
    def resolve
      Ohai::System.new.all_plugins('hostname').first.data['fqdn']
    end

    def associate_eip(hostname)
      # load credentials
      # query for eips
      # highline menu for selection
      # associate to instanceA
      hostname
    end

    def write_chef_json(file_path, hostname)
      File.write(
        file_path,
        JSON.pretty_generate(
          'set_fqdn' => hostname, 'run_list' => ['recipe[hostname::default]']
        )
      )
    end
  end
end

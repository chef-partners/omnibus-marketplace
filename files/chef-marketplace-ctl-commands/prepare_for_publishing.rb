require "highline/import"

add_command_under_category "prepare-for-publishing", "Publishing", "Prepare the node for publishing", 2 do
  ui = HighLine.new
  agree = ARGV.any? { |v| v =~ /yes/i }

  msg = "Preparing the node for publishing will remove _all_ SSH Keys and\n"
  msg << "Chef configuration and Data. Please type 'yes' to proceed:"

  exit(1) unless agree || ui.ask("<%= color(%Q(#{msg}), :yellow) %>") =~ /yes/i

  ui.say("Preparing the node for publishing...")

  json_file = "/opt/chef-marketplace/embedded/cookbooks/prepare_for_publishing.json"
  json_content = JSON.pretty_generate("run_list" => ["chef-marketplace::prepare_for_publishing"])
  File.write(json_file, json_content)
  status = run_chef(json_file, "--lockfile /tmp/chef-client-prepare-for-publishing.lock")
  status.success? ? exit(0) : exit(1)
end

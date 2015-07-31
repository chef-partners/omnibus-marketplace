require 'json'

add_command_under_category 'test', 'Test', 'Test that the Chef Server Marketplace addtions are working properly', 2 do
  statuses = []

  ctl_rspec = [
    '/opt/chef-marketplace/embedded/bin/rspec',
    '-I /opt/chef-marketplace/embedded/service/omnibus-ctl/spec',
    '/opt/chef-marketplace/embedded/service/omnibus-ctl/',
    '--format documentation',
    '--color'
  ].join(' ')

  statuses << run_command(ctl_rspec).exitstatus

  # If the Chef Server has been set up make sure the ctl commands work
  if File.exist?('/etc/opscode/chef-server-running.json')
    setup_cmd = [
      'chef-server-ctl marketplace-setup',
      '-f john',
      '-l doe',
      '-e john@doe.dead',
      '-u johndoedeadcheftest',
      '-o johhdoedeadcheftestorg',
      '-p password',
      '--yes'
    ].join(' ')

    statuses << run_command(setup_cmd).exitstatus

    # clean up
    run_command('chef-server-ctl org-delete johhdoedeadcheftestorg -y')
    run_command('chef-server-ctl user-delete johndoedeadcheftest -y')
  end

  exit(statuses.all? { |s| s == 0 } ? 0 : 1)
end

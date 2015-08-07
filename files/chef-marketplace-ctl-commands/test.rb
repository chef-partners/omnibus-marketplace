add_command_under_category 'test', 'Configuration', 'Test that the Chef Server Marketplace addtions are working properly', 2 do
  puts 'Running chef-marketplace unit tests..'
  statuses = {}

  ctl_rspec = [
    'cd /opt/chef-marketplace &&',
    '/opt/chef-marketplace/embedded/bin/rake spec --trace'
  ].join(' ')

  statuses['rspec'] = run_command(ctl_rspec).exitstatus

  # If the Chef Server has been set up make sure the ctl commands work
  if File.exist?('/etc/opscode/chef-server-running.json')
    puts 'Chef Server detected, running chef-marketplace functional tests..'
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

    statuses['marketplace_setup'] = run_command(setup_cmd).exitstatus

    # verify that the user and org were created
    statuses['org_show'] = run_command('chef-server-ctl org-show johhdoedeadcheftestorg').exitstatus
    statuses['user_show'] = run_command('chef-server-ctl user-show johndoedeadcheftest').exitstatus

    # clean up
    statuses['org_delete'] = run_command('chef-server-ctl org-delete johhdoedeadcheftestorg -y').exitstatus
    statuses['user_delete'] = run_command('chef-server-ctl user-delete johndoedeadcheftest -y').exitstatus
  end

  statuses.select { |_, code| code != 0 }.each { |cmd, code| puts "ERROR: test '#{cmd}' failed with code #{code}" }

  exit(statuses.values.all? { |s| s == 0 } ? 0 : 1)
end

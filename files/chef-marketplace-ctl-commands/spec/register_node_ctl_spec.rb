require 'spec_helper'
require 'shellwords'
require 'json'

describe 'chef-marketplace-ctl register-node' do
  let(:marketplace_ctl) { OmnibusCtlTest.new('register_node') }
  let(:omnibus_ctl) { marketplace_ctl.plugin }
  let(:process_success) { double('Process::Status', success?: true, exitstatus: 0) }
  let(:role) { 'aio' }
  let(:register_json_file) { '/opt/chef-marketplace/embedded/cookbooks/register_node.json' }
  let(:register_json_config) do
    {
      'chef-marketplace' => {
        'registration' => {
          'address' => 'https://marketplace.chef.io',
          'first_name' => contact_first_name,
          'last_name' => contact_last_name,
          'organization' => contact_org_name,
          'email' => contact_email
        }
      },
      'run_list' => ['chef-marketplace::register_node']
    }
  end

  before do
    allow(omnibus_ctl).to receive(:run_chef).and_return(process_success)
    allow(File)
      .to receive(:exist?)
      .with('/etc/chef-marketplace/chef-marketplace-running.json')
      .and_return(false)
    allow(File)
      .to receive(:write)
      .with(register_json_file, JSON.pretty_generate(register_json_config))
      .and_return(true)
  end

  shared_examples 'a proper registration' do
    it 'writes the config json, converges the registration recipe, and exits properly' do
      expect(File)
        .to receive(:write)
      expect(omnibus_ctl)
        .to receive(:run_chef)
        .with(register_json_file, '--lockfile /tmp/chef-client-register-node.lock')
      expect { marketplace_ctl.execute(command) }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  context 'when no arguments are given' do
    let(:highline) { double('HighLine', ask: 'user-defined') }
    let(:contact_first_name) { 'user-defined' }
    let(:contact_last_name) { 'user-defined' }
    let(:contact_email) { 'user-defined' }
    let(:contact_org_name) { 'user-defined' }

    before { allow(HighLine).to receive(:new).and_return(highline) }

    it 'it prompts the user for missing arguments' do
      # receive ask for email, first, last, and org
      expect(highline).to receive(:ask).exactly(4).times
      expect { marketplace_ctl.execute('register-node') }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  context 'with arguments are given' do
    let(:contact_first_name) { 'Gary' }
    let(:contact_last_name) { 'Busey' }
    let(:contact_email) { 'gbusey@teeth.com' }
    let(:contact_org_name) { 'Donelly Inc.' }
    let(:command) do
      ['register-node',
       "-f #{contact_first_name}",
       "-l #{contact_last_name}",
       "-e #{contact_email}",
       "-o #{Shellwords.shellescape(contact_org_name)}"
      ].join(' ')
    end

    it_behaves_like 'a proper registration'
  end
end

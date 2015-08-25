require 'spec_helper'

describe 'chef-marketplace-ctl upgrade' do
  let(:marketplace_ctl) { OmnibusCtlTest.new('upgrade') }
  let(:omnibus_ctl) { marketplace_ctl.plugin }
  let(:process_success) { double('Process::Status', success?: true, exitstatus: 0) }

  before do
    allow(marketplace_ctl.plugin).to receive(:run_chef).and_return(process_success)
  end

  context 'when no arguments are given' do
    it 'raises an error' do
      expect { marketplace_ctl.execute('upgrade') }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  context 'with --yes' do
    it "runs the both upgrade recipes and exit's cleanly" do
      expect(omnibus_ctl).to receive(:run_chef)
        .with('/opt/upgrade/embedded/cookbooks/upgrade-marketplace.json',
              '--lockfile /tmp/chef-client-upgrade.lock')
      expect(omnibus_ctl).to receive(:run_chef)
        .with('/opt/upgrade/embedded/cookbooks/upgrade-chef-server.json',
              '--lockfile /tmp/chef-client-upgrade.lock')
      expect { marketplace_ctl.execute('upgrade --yes') }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  context 'with -s' do
    it "runs the chef server upgrade recipe and exit's cleanly" do
      expect(omnibus_ctl).to_not receive(:run_chef)
        .with('/opt/upgrade/embedded/cookbooks/upgrade-marketplace.json',
              '--lockfile /tmp/chef-client-upgrade.lock')
      expect(omnibus_ctl).to receive(:run_chef)
        .with('/opt/upgrade/embedded/cookbooks/upgrade-chef-server.json',
              '--lockfile /tmp/chef-client-upgrade.lock')
      expect { marketplace_ctl.execute('upgrade -s') }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  context 'with -m' do
    it "runs the marketplace upgrade recipe and exit's cleanly" do
      expect(omnibus_ctl).to receive(:run_chef)
        .with('/opt/upgrade/embedded/cookbooks/upgrade-marketplace.json',
              '--lockfile /tmp/chef-client-upgrade.lock')
      expect(omnibus_ctl).to_not receive(:run_chef)
        .with('/opt/upgrade/embedded/cookbooks/upgrade-chef-server.json',
              '--lockfile /tmp/chef-client-upgrade.lock')
      expect { marketplace_ctl.execute('upgrade -m') }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end
end

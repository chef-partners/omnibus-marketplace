require 'spec_helper'

def config_file_for(product)
  "/opt/upgrade/embedded/cookbooks/upgrade-#{product.tr('_', '-')}.json"
end

describe 'chef-marketplace-ctl upgrade' do
  let(:marketplace_ctl) { OmnibusCtlTest.new('upgrade') }
  let(:omnibus_ctl) { marketplace_ctl.plugin }
  let(:process_success) { double('Process::Status', success?: true, exitstatus: 0) }

  before do
    allow(marketplace_ctl.plugin).to receive(:run_chef).and_return(process_success)
    allow(File)
      .to receive(:exist?)
      .with('/etc/chef-marketplace/chef-marketplace-running.json')
      .and_return(false)
  end

  shared_examples 'a proper upgrade' do
    let(:unexpected_products) { %w(aio chef_server marketplace analytics) - required_products }

    it "converges the right recipes and exit's cleanly" do
      required_products.each do |product|
        expect(omnibus_ctl)
          .to receive(:run_chef)
          .with(config_file_for(product), '--lockfile /tmp/chef-client-upgrade.lock')
      end

      unexpected_products.each do |product|
        expect(omnibus_ctl)
          .to_not receive(:run_chef)
          .with(config_file_for(product), '--lockfile /tmp/chef-client-upgrade.lock')
      end

      expect { marketplace_ctl.execute(command) }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  context 'when no arguments are given' do
    it 'raises an error' do
      expect { marketplace_ctl.execute('upgrade') }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  context 'with --yes' do
    let(:command) { 'upgrade --yes' }

    context 'when a role is configured' do
      before do
        allow(File)
          .to receive(:exist?)
          .with('/etc/chef-marketplace/chef-marketplace-running.json')
          .and_return(true)
        allow(IO)
          .to receive(:read)
          .with('/etc/chef-marketplace/chef-marketplace-running.json')
          .and_return(json)
      end

      let(:json) { { 'chef-marketplace' => { 'role' => role } }.to_json }

      context 'when the role is analytics' do
        let(:role) { 'analytics' }
        let(:required_products) { %w(analytics marketplace) }

        it_behaves_like 'a proper upgrade'
      end

      context 'when the role is a chef server' do
        let(:role) { 'server' }
        let(:required_products) { %w(chef_server marketplace) }

        it_behaves_like 'a proper upgrade'
      end

      context 'when the role is an All-In-One' do
        let(:role) { 'aio' }
        let(:required_products) { %w(chef_server analytics marketplace) }

        it_behaves_like 'a proper upgrade'
      end
    end

    context 'when there is no role configured' do
      let(:required_products) { %w(chef_server analytics marketplace) }

      it_behaves_like 'a proper upgrade'
    end
  end

  context 'with -s' do
    let(:command) { 'upgrade -s' }
    let(:required_products) { %w(chef_server) }

    it_behaves_like 'a proper upgrade'
  end

  context 'with -m' do
    let(:command) { 'upgrade -m' }
    let(:required_products) { %w(marketplace) }

    it_behaves_like 'a proper upgrade'
  end

  context 'with -a' do
    let(:command) { 'upgrade -a' }
    let(:required_products) { %w(analytics) }

    it_behaves_like 'a proper upgrade'
  end
end

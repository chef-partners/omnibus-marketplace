require_relative '../../marketplace/setup'
require 'spec_helper'
require 'ostruct'

describe Marketplace::Setup do
  subject { described_class.new(options, omnibus_ctl) }

  let(:options) { OpenStruct.new }
  let(:omnibus_ctl) { double('OmnibusCtl') }
  let(:current_hostname) { 'current.hostname.com' }
  let(:json) { { 'chef-marketplace' => { 'role' => 'tofu' } }.to_json }

  before do
    # Stub out the role
    allow(File)
      .to receive(:exist?)
      .with('/etc/chef-marketplace/chef-marketplace-running.json')
      .and_return(true)
    allow(IO)
      .to receive(:read)
      .with('/etc/chef-marketplace/chef-marketplace-running.json')
      .and_return(json)
  end

  describe '#setup' do
    before do
      allow(subject).to receive(:role).and_return(role)
      allow(subject).to receive(:redirect_to_webui).and_return(true)
      allow(subject).to receive(:reconfigure_marketplace).and_return(true)
      allow(subject).to receive(:update_software).and_return(true)
      allow(subject).to receive(:validate_options).and_return(true)
      allow(subject).to receive(:agree_to_eula).and_return(true)
      allow(subject).to receive(:validate_payment).and_return(true)
    end

    context 'when the role is server' do
      let(:role) { 'server' }

      it 'sets up the chef server' do
        allow(subject).to receive(:setup_server).and_return(true)
        expect(subject).to receive(:setup_server)

        subject.setup
      end
    end

    context 'when the role is analytics' do
      let(:role) { 'analytics' }

      it 'sets up chef analytics' do
        allow(subject).to receive(:setup_analytics).and_return(true)
        expect(subject).to receive(:setup_analytics)

        subject.setup
      end
    end

    context 'when the role is aio' do
      let(:role) { 'aio' }

      it 'sets up chef server and analytics' do
        allow(subject).to receive(:setup_aio).and_return(true)
        expect(subject).to receive(:setup_aio)

        subject.setup
      end
    end
  end

  describe '#role' do
    context 'when chef-marketplace has been configured' do
      it 'loads the role from the running json' do
        expect(subject.send(:role)).to eq('tofu')
      end
    end

    context 'when chef marketplace has not been configured' do
      before do
        allow(File)
          .to receive(:exist?)
          .with('/etc/chef-marketplace/chef-marketplace-running.json')
          .and_return(false)
      end

      it 'raises a system exit' do
        expect { subject.send(:role) }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end
    end
  end
end

require 'spec_helper'
require 'marketplace/reckoner'
require 'marketplace/reckoner/updater/ec2'
require 'time'

describe Marketplace::Reckoner::Updater::Ec2 do
  subject { described_class.new }

  let(:usage_meter) { double('Aws::MeteringService::Client') }
  let(:free_node_count) { 5 }
  let(:time) { Time.parse('2016-01-12 23:04:02 UTC') }

  before do
    Marketplace::Reckoner::Config['aws']['dry_run'] = false
    Marketplace::Reckoner::Config['aws']['region'] = 'us-west-1'
    Marketplace::Reckoner::Config['aws']['product_code'] = 'MidasGutz'
    Marketplace::Reckoner::Config['aws']['usage_dimension'] = 'SeriousGutsCompentition'
    Marketplace::Reckoner::Config['updater']['driver'] = 'ec2'
    Marketplace::Reckoner::Config['license']['free'] = free_node_count

    allow(Aws::MeteringService::Client).to receive(:new).with(region: 'us-west-1').and_return(usage_meter)
    allow(Time).to receive_message_chain(:now, :utc).and_return(time)
    allow(subject).to receive(:load_credentials).and_return(true)
  end

  describe '#update' do
    it 'updates with the adjusted total' do
      expect(usage_meter).to receive(:meter_usage).with(
        product_code: 'MidasGutz',
        timestamp: time,
        usage_dimension: 'SeriousGutsCompentition',
        usage_quantity: 666 - free_node_count,
        dry_run: false
      )

      subject.update(666)
    end
  end
end

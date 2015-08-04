require 'spec_helper'
require 'ostruct'

describe 'chef-marketplace-ctl setup' do
  shared_examples_for 'chef-marketplace-ctl cli arguments' do
    let(:marketplace_ctl) do
      @ctl = OmnibusCtlTest.new('setup')
      # Omnibus::Ctl will Kernel#eval the Marketplace source so we have to stub
      # after we create the object
      allow(Marketplace).to receive(:setup).and_return(true)
      @ctl
    end

    it 'should properly parse the value from ARGV and add it to the options' do
      # mock options
      opts = OpenStruct.new
      opts[option_name] = option_value

      # agree_to_eula is set by default so expect it unless --yes is passed
      opts['agree_to_eula'] = false unless option_name == 'agree_to_eula'

      expect(Marketplace).to receive(:setup).with(opts, marketplace_ctl.plugin)
      expect(Kernel).to_not receive(:eval)

      marketplace_ctl.execute("setup #{input}")
    end
  end

  # rubocop:disable Style/SpaceInsideBrackets
  [
    ['-y',                      'agree_to_eula',  true                ],
    [ '-u julia',               'username',       'julia'             ],
    [ '-p drowssap',            'password',       'drowssap'          ],
    [ '-f julia',               'first_name',     'julia'             ],
    [ '-l child',               'last_name',      'child'             ],
    [ '-e julia@child.com',     'email',          'julia@child.com'   ],
    [ '-o marvelous',           'organization',   'marvelous'         ]
  ].each do |params|
    context "when the input is #{params[0]}" do
      it_behaves_like 'chef-marketplace-ctl cli arguments' do
        let(:input) { params[0] }
        let(:option_name) { params[1] }
        let(:option_value) { params[2] }
      end
    end
  end
end

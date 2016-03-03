include_recipe 'chef-marketplace::_runit_prepare'

runit_service 'reckoner' do
  action :disable
end

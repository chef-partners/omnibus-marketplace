case node['platform']
when 'redhat'
  execute 'subscription-manager repos --enable rhel-7-server-rh-common-rpms' do
    not_if 'subscription-manager repos --list-enabled | grep rhel-7-server-rh-common-rpms'
    only_if 'subscription-manager repos --list | grep rhel-7-server-rh-common-rpms'
  end
when 'centos'
  %w(base extras plus updates).each do |repo|
    node.set['yum'][repo]['enabled'] = true
    node.set['yum'][repo]['managed'] = true
  end

  include_recipe 'yum-centos::default'
when 'ubuntu'
  include_recipe 'apt::default'
end

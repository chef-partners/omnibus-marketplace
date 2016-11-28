# Possibly run actions
bash 'delivery-ctl reconfigure' do
  code 'delivery-ctl reconfigure'
  only_if { delivery_configured? }
  action :nothing
end

bash 'delivery-ctl start' do
  code 'delivery-ctl start'
  only_if { delivery_configured? }
  action :nothing
end

# Chef Automate
chef_ingredient 'delivery' do
  action :upgrade
  channel :current # TODO: change this back to stable when we've got the release out

  notifies :run, 'bash[delivery-ctl reconfigure]', :immediately
  notifies :run, 'bash[yum-clean-all]', :immediately
  notifies :run, 'bash[apt-get-clean]', :immediately
end

bash 'delivery-ctl restart' do
  code 'delivery-ctl restart'
  only_if { delivery_configured? }
end

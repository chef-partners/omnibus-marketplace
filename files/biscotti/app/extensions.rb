module Biscotti
  module Extensions
    autoload :BakeryDSL, "app/extensions/bakery_dsl"
    autoload :SetupDSL, "app/extensions/setup_dsl"
    autoload :ChefAPI, "app/extensions/chef_api"
    autoload :DelivAPI, "app/extensions/deliv_api"
  end
end

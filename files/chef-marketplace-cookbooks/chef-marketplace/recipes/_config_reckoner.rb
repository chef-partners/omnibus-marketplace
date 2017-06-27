if node["chef-marketplace"]["role"] =~ /aio|server|automate/
  node.default["chef-marketplace"]["reckoner"]["usage_dimension"] = "ChefNodes"
elsif node["chef-marketplace"]["role"] == "compliance"
  node.default["chef-marketplace"]["reckoner"]["usage_dimension"] = "ComplianceNodes"
end

node.default["chef-marketplace"]["reckoner"]["enabled"] if node["chef-marketplace"]["license"]["type"] == "flexible"

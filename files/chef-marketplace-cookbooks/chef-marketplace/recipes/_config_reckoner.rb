if node["chef-marketplace"]["role"] =~ /aio|server/
  node.set["chef-marketplace"]["reckoner"]["usage_dimension"] = "ChefNodes"
elsif node["chef-marketplace"]["role"] == "compliance"
  node.set["chef-marketplace"]["reckoner"]["usage_dimension"] = "ComplianceNodes"
end

node.set["chef-marketplace"]["reckoner"]["enabled"] if node["chef-marketplace"]["license"]["type"] == "flexible"

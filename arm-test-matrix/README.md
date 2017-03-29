# Azure Solution Template test tools

This is a proof of concept tool to run the 30 ARM test lauches that are
required to publish in the Azure Marketplace. The 30+ permutations should cover
the following cases:

* Using default inputs where possible
* Using non-default inputs where possible
* Using all Azure regions
* Using different storage account types where possible
* Using different VM sizes 
* Using different virtual network settings
* Using different public IP address settings
* Reusing existing resources where possible

It reads in a given set of default parameters and runs all defined scenarios in
parellel by slightly modifying the default parameters with the desired
permutations.

For test cases that require setup or taredown you can optionally provide those
commands.

Currently this tool requires the Azure CLI and performs all the commands by
shelling out to the CLI. At a later date we might want to consider changing
this to use a real gem and the Azure API directly.

Run the Automate matrix tests:

```shell
azure login
bundle install
bundle exec ruby automate_matrix.rb /path/to/mainTemplate.json /path/to/mainTemplateParameters.json
```

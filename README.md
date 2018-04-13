chef-marketplace Omnibus project
================================
This project creates full-stack platform-specific packages for
the `chef-marketplace` Chef server add-on.  This add-on extends the Chef server's
support for cloud marketplaces.

All The Things
--------------
1. [Configuration](#configuration)
  * [Example marketplace.rb](#example-marketplace-config)
  * [Deprecated Features](#deprecated-features)
1. [chef-marketplace-ctl](#chef-marketplace-ctl)
  * [chef-marketplace-ctl setup](#setup)
  * [chef-marketplace-ctl reconfigure](#reconfigure)
  * [chef-marketplace-ctl upgrade](#upgrade)
  * [chef-marketplace-ctl hostname](#hostname)
  * [chef-marketplace-ctl trim-actions-db](#trim-actions-db)
  * [chef-marketplace-ctl register-node](#register-node)
  * [chef-marketplace-ctl prepare-for-publishing](#prepare-for-publishing)
  * [chef-marketplace-ctl test](#test)
1. [Biscotti Sevice](#biscotti-service)
1. [Reckoner Sevice](#reckoner-service)
1. [Azure Solution Template](#azure-solution-template)
  * [Using the template](#using-the-template)
  * [Developing the template](#developing-the-template)
  * [Testing changes](#testing-changes)
  * [Publishing the template](#publishing-the-template)
1. [Kitchen-Based Build Environment](#kitchen-based-build-environment)
1. [Contributing](#contributing)

Configuration
-------------
The `chef-marketplace` package supports a number of user supplied customization
options.  Like the majority of Chef products, the syntax is `Mixlib::Config`
based and the file should be located at `/etc/chef-marketplace/marketplace.rb`

#### Example Marketplace Config
```ruby
# Enable or disable changing the motd
motd.enable = true

# Marketplace specific support email address
support.email = 'some@email.com'

# Marketplace specific documentation
documentation.url = 'http://myorg.com/docs'

# The amount of nodes the license includes
license.count '25'

# The billing type
license.type 'fixed'

# Which role the instance is supposed to play
role 'aio' # or 'server' or 'automate'

# Which Cloud Platform the instance is running on
platform 'aws' # or 'azure'

# Default user for cloud-init
user 'ec2-user'

# Prevents commands from attempting to use external services like package mirrors
# Changing this setting will disable certain features
disable_outbound_traffic true

# Configure which port the Analytics UI binds to
analytics.ssl_port = 8443

# Enable or disable the actions auto trim
analytics.trimmer.enabled = true

# How often in hours to run (1-23)
analytics.trimmer.interval = 4

# Enable or disable the reporting auto clean-up
reporting.cron.enabled = true

# Standard crontab expression
reporting.cron.expression = '*/2 * * * *'

# The latest year/month in the reporting database that you want to preserve
reporting.cron.year = 'date +%Y'
reporting.cron.month = 'date +%m'

# Enable/Disable the Reckoner billing daemon
reckoner.enabled = true

# Set the ec2 product code for the ec2 updater
reckoner.product_code = 'XXXXXXXXXXXXXXXXXXXX'

# Enable/Disable the biscotti service
biscotti.enabled = true

# Enable/Disable the Manage marketplace sign up
manage.marketplace.sign_up.enabled = true
```

### Deprecated Features
In the older Chef Server AIO images the chef-marketplace package utilized the
chef-marketplace plugin system. It did this to ease configuring Chef Analytics
and and oc-id. In this scenario the following configuration was required:

* The `role` **_must_** be configured in the `marketplace.rb` file
* The `topology` **_must_** be set to `chef-marketplace` in the
  `chef-server.rb` configuration file

In Chef Automate marketplace images this is not required as Chef Analytics is
not included.

#### Example Server Config
```ruby
topology 'chef-marketplace'
```

chef-marketplace-ctl
--------------------
### Setup
`chef-marketplace-ctl setup` is a helper command that sets up the Chef server,
Manage, Reporting and Analytics with user provided configuration options.

As 0.0.8 web based setup is available for both Chef Server and Chef Analytics.
While this command can still be used the web based setup is preferred.

#### Options
* `-u USERNAME, --username USERNAME` Admin username
* `-p PASSWORD, --password PASSWORD` Admin password
* `-f FIRSTNAME, --firstname FIRSTNAME` Admin first name
* `-l LASTNAME, --lastname LASTNAME` Admin last name
* `-e EMAIL, --email EMAIL` Admin email address
* `-o ORGNAME, --org ORGNAME` Default organization name
* `-y, --yes` Agree to all setup questions
* `--register` Agree to register the node with Chef Software
* `--eula` Agree to Chef Software's End User License Agreement
* `--preconfigure` Preconfigure the requires services
* `--debug` Output logs from executed commands to STDOUT.
* `-h, --help` Display help information

### Reconfigure
After package installation `chef-marketplace-ctl reconfigure` is run to execute
the embedded configuration recipes.

#### Configuration Options
See the [marketplace.rb](#example-marketplace-config) configuration for a list of
user configurable attributes.

### Upgrade
`chef-marketplace-ctl upgrade` will upgrade the installed Chef server packages

#### Options
`-y, --yes` Upgrade Marketplace and all installed components for the
  configured role
`-s, --server` Upgrade Chef Server (Reporting and Manage are also updated in AIO mode)
`-m, --marketplace` Upgrade Marketplace
`-a, --analytics` Upgrade Chef Analytics
`-c, --compliance` Upgrade Chef Compliance
`-d, --automate` Upgrade Chef Automate

### Hostname
`chef-marketplace-ctl hostname` will set or return the system hostname.  If the
hostname is updated it will automatically reconfigure any required Chef Software
packages.

#### Options
None, when passing a string to the command it will attempt to configure the
host's FQDN to the string that is passed.  If nothing is passed it will return
the current FQDN.

### Trim Actions DB
`chef-marketplace-ctl trim-actions-db` will trim the actions database to prevent
accidental over-filling of the disk.  This command is run on regular intervals
via cron.

#### Options
* `-s, --size` The desired size of the Analytics database
  configured role
* `-l, --log` The location of the trimmer log file
* `-i, --interval` How often the trimmer is running

### Register Node
`chef-marketplace-ctl register-node` will register the Marketplace node with
Chef Software to enable support.  This command is automatically run during the
setup command or via the WebUI during the Chef Compliance setup.

#### Options
* `-f, --first` The support contacts first name
* `-l, --last` The support contacts last name
* `-e, --email` The support contacts email address
* `-o, --organization` The name of the organization the contact represents
* `-s, --server` The address of the marketplace registration API

### Prepare For Publishing
`chef-marketplace-ctl prepare-for-publishing` Will setup the node for Marketplace
publishing.  This ensures all cloud-init and ssh packages are installed and
configured.  It also removes all default ssh keys, chef package config, default
state, and shell history.

### Test
`chef-marketplace-ctl test` Perform's unit and functional tests to validate a
successful package installation and working build. This is run in our development
continuous delivery pipeline to ensure the package works as expected.

### Debugging
The`setup` subcommand has a `--debug` option which can be used to get detailed 
output from all the commands run during the preconfigure process. This can be
added to the Azure ARM template or AWS CloudFormation template as needed.

#### Azure
Logs from the ARM template script can be found here:
`/var/log/azure/Microsoft.OSTCExtensions.CustomScriptForLinux/1.5.2.2/extension.log`

The script itself can be found here:
`/var/lib/waagent/Microsoft.OSTCExtensions.CustomScriptForLinux-1.5.2.2/download/0/`

##### Adding debug option
To add the `--debug` flag, you will need to modify the command executed here:
https://github.com/chef-partners/omnibus-marketplace/blob/master/arm-templates/automate/automate_setup.rb#L45

#### AWS
We currently have to offerings in AWS which operate slightly differenly in the
manner in which they are provisioned. The BYOL version uses CloudFormation,
while the Metered offering includes a pre-baked init script. With the
CloudFormation template, you can make the change and test with no other
modifications or actions required.

However, since the metered version has the scriped baked into the AMI,
both a new version of the chef-marketplace and a new AMI build will be required 
to be able to use the change.

##### Adding the debug option
###### BYOL
To add the `--debug` flag, you will need to modify the CloudFormation template similar
to the example below:

```
--- a/cloudformation/marketplace_byol.yml
+++ b/cloudformation/marketplace_byol.yml
@@ -257,7 +257,7 @@ Resources:
             - !If
               - HasLicenseUrl
               - !Sub >-
-                chef-marketplace-ctl setup --preconfigure --license-url ${LicenseUrl}
+                chef-marketplace-ctl setup --preconfigure --license-url ${LicenseUrl} --debug 2>&1 >/var/log/cfn-userdata.log
               - chef-marketplace-ctl setup --preconfigure
```

It may also be helpful to change the `cfn-signal` command to always return `0`
rather than `$?` if your instance is getting terminated due to a failure.

Warning: The output will contain sensitive information such as private keys.
Do not keep this flag enabled for production deployments.

###### Metered
To add the `--debug` flag to a metered AMI, modify the preconfigure command here:

https://github.com/chef-partners/omnibus-marketplace/blob/master/files/chef-marketplace-cookbooks/chef-marketplace/templates/default/chef-marketplace-cloud-init-setup.erb

The following is an example of the required change:
```
--- a/files/chef-marketplace-cookbooks/chef-marketplace/templates/default/chef-marketplace-cloud-init-setup.erb
+++ b/files/chef-marketplace-cookbooks/chef-marketplace/templates/default/chef-marketplace-cloud-init-setup.erb
@@ -3,6 +3,7 @@ export HOME="/root"
 
 mkdir -p /var/opt/chef-marketplace/
 touch /var/opt/chef-marketplace/cloud_init_running
-chef-marketplace-ctl setup --preconfigure && touch /var/opt/chef-marketplace/preconfigured
+chef-marketplace-ctl setup --preconfigure --debug 2>&1 >>/var/log/userdata.log && \
+touch /var/opt/chef-marketplace/preconfigured
```

Biscotti Sevice
---------------
TODO: Add documentation regarding the `biscotti` martketplace service.

Reckoner Sevice
---------------
TODO: Add documentation regarding the `reckoner` martketplace service.

Azure Solution Template
----------------------
With the Chef Automate Azure Marketplace offering we decided to take a simpler
approach to the marketplace offering and limit the scope to a single Azure
Solution Template for provisioning and configuring a BYOL Chef Automate
virtual machine in the Azure cloud. We use the image artifact that is
created and publised via the `marketplace_image` repository as our base image
reference in the solution template. Prior Chef Server AIO Marketplace releases
were images only.

### Using the template
There are several options for using the Solution Template. If you want to test
or use what is publicly available in the marketplace, login to the Azure
portal and search the Marketplace for `Chef Automate`. If you're using Chef's
primary subscription you may also see `Chef Automate (Staged)` which is the
latest staged offer that we're working to publish. To launch it, fill out all
required options, agree to the purchase agreement and launch it. After the
ARM deployment has completed you'll need to access the setup page, complete the
setup and download the stater kit. The deployment outputs should include the
`chefAutomateURL` that you'll need to complete the setup.

```shell
Outputs            :
Name             Type    Value
---------------  ------  ---------------------------------------------------------------
fqdn             String  automatetestvm.eastus.cloudapp.azure.com
sshCommand       String  ssh azure@automatetestvm.eastus.cloudapp.azure.com
chefAutomateURL  String  https://automatetestvm.eastus.cloudapp.azure.com/biscotti/setup
```

You can manually launch the latest template via Make:

`make arm-test`

or via the Azure CLI with:

```shell
azure login
azure group create -n "yournewresourcegroup" -l "East US"
azure group deployment create \
  -f ./arm-templates/automate/mainTemplate.json \
  -e ./arm-templates/automate/mainTemplateParameters.json \
  -g yournewresourcegroup
```




### Developing the template
The Azure Marketplace Solution Template comprises of a UI definition, a
corresponding Azure Resource Manager(ARM) template, and any included ARM
sub-templates, extension scripts, and files.

The UI definition file is comprised of Marketplace UI Elements
which will define the UI experience in the Marketplace. Anything that is user
defined and required in the ARM templates will need to be exported via
the definition outputs which must correspond to the parameter inputs in the
ARM template.

### Testing changes
The sub-template import model in Azure requires that all templates that are
conditionally used be available as a web resource. Therefore, when
making modifications you'll always want to push your template and UI changes to
a feature branch and update the the `baseUrl` parameter in
`arm-templates/automate/mainTemplateParameters.json` to be your new feature
branch.

You may to create the deployment group before you can test any changes. To do
this run, `azure group create -n automatearmtest -l eastus` or 
`az group create --name automatearmtest -l "East US"` depending on the Azure CLI
version you are using.

Use `make arm-validate` to validate the ARM template via the ARM API and verify
that the the UI definition schema validates against the JSON schema. *You must
fix _any_ errors here in order to publish.*

Use `make-ui-test-href` to generate an Azure Portal href that you can paste into
your browsers address bar to open your UI Definition in the Azure Portal. This
is useful because you can iterate on a UI definition quickly without requiring
a staged Solution Template. It's also conveninent as it doesn't initiate an ARM
template launch so you don't have to create resources when working on UI. It also
displays the outputs of the UI defition in your browsers Javascript console when
you use the launch button. You can use that to verify the output of the UI
definition match the ARM template parameters.

Use `make arm-run-test-matrix` to run the full test matrix to ensure there are
no regressions. This can take a few hours.

#### Configuring the Azure Instance type
In some cases you will find a need to configure a specific Azure instance type.
This can be done by setting the value for `vmSize` in
`arm-templates/automate/mainTemplateParameters.json`.

#### Launching a Single Instance
To create a single Azure instance for testing, you can run the command:
`make arm-test`. This VM instance can be found in the Azure account under the
resource group `automatearmtest`.

The SSH username and password can be found in the `adminUsername` and 
`adminPassword` parameters of the `arm-templates/automate/mainTemplateParameters.json`
file.

### Publishing the template
In order to publish the template all work on the feature branch must be merged
to master. After this has happened you will need to create a Solution Template
archive with the UI definition, the main ARM template and all nested sub-templates
and extensions that the ARM template requires.

#### Stage published template
Use `make arm-publish` to validate the template and create a zip file.

1. Login to the [Azure Cloud Partner Portal](https://cloudpartner.azure.com)
1. Go the "All offers" section.
1. Choose "Chef Automate" from the list of offers. Note the ARM Solution Template
is a different offer than the VM image.
1. From the "Chef Automate" offer, click on the "SKUs" section and select the 
"allinone" sku.
1. Scroll to the bottom of "Package Details" and click "New Package."
1. Provide a version for the ARM template and click "Upload." Select the zip file
artifact generated by `make arm-publish`.
1. Click "Save."
1. Click "Publish."

After the staging has completed (can be several hours to several days) you will
need to test the template.

#### Test the staged template
Testing the staged template involves testing both the all UI permutations and
a minimum of 30 ARM template launches.

Near complete testing of UI elements is currently possible in 3 passes. The goal
here is to validate all branching options in the template (storage types,
regions, SSH auth, existing resource re-use, etc.) For all three passes below
you'll need to locate the staged template in the Azure Marketplace and run
through each scenario while ensuring that you complete the setup and validate
a working Chef Automate install.

##### Pass #1 (defaults)
* Use defaults where possible
* Use SSH Password auth
* Don't upload a `delivery.license` file

##### Pass #2 (re-use)
* Delete resources that won't be re-used from pass #1:
  * The virtual machine
  * The network interface
  * The network security group
* Re-use existing resources from Pass #1 for all resource types that support it:
  * The public IP address
  * The storage account
  * The diagnostic storage account
  * The virtual network

##### Pass #3 (non-defaults)
* Use non default options wherever possible:
  * The virtual machine name
  * The username
  * Use SSH Public Key auth
  * Use a region that is not `East US`
  * Use a VM size that is not `Standard_D2_v2`
  * Use a premium storage account for disks
  * Use a different subnet
  * Upload a `delivery.license` file

If all three of these scenarios complete without error you should be reasonably
confident that the UI definition and ARM template work as expected. Now you'll
need to run the test matrix. This process will run the master branch version of
the ARM template (which should be the version staged) 30+ times to verify that
it works as expected in several permutations. Currently it verifies usability in
all regions, using new resources, reusing existing resources and using different
storage types. If your changes create a new permutation it is advised to add a
secenario to the automate test matrix to ensure that it is verified.

Use `make arm-run-test-matrix` to run the tests. If the tests succeed a zip
artifact containing the logs of each run will be output. You'll need to provide
the log archive to Microsoft when you request publishing to production.

Though each scenario cleans up after itself you should make sure to manually 
delete any lingering test resouces and/or resource groups.

Kitchen-based Build Environment
-------------------------------
Every Omnibus project ships will a project-specific
[Berksfile](http://berkshelf.com/) that will allow you to build your omnibus
projects on all of the projects listed in the `.kitchen.yml`. You can
add/remove additional platforms as needed by changing the list found in the
`.kitchen.yml` `platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However,
there is nothing that restricts you to building on other platforms. Simply use
the [omnibus cookbook](https://github.com/opscode-cookbooks/omnibus) to setup
your desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local
development. Test Kitchen also exposes the ability to provision instances using
various cloud providers like AWS, DigitalOcean, or OpenStack. For more
information, please see the [Test Kitchen documentation](http://kitchen.ci).

Once you have tweaked your `.kitchen.yml` (or `.kitchen.local.yml`) to your
liking, you can bring up an individual build environment using the `kitchen`
command.

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.

```shell
$ bin/kitchen converge centos-6.6
```

Then login to the instance and build the project

```shell
$ bundle exec kitchen login centos-6.6
[vagrant@centos...] $ cd chef-marketplace
[vagrant@centos...] $ bundle install --binstubs
[vagrant@centos...] $ bin/omnibus build chef-marketplace
```

The platform/architecture type of the package created will match the platform
where the `build project` command is invoked. For example, running this command
on a MacBook Pro will generate a Mac OS X package. After the build completes
packages will be available in the `pkg/` folder.

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean chef-marketplace
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/chef-marketplace`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean chef-marketplace --purge
```

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Contributing
------------
Please submit a GitHub issue with any problems you encounter.

Contributions are always welcome!  If you'd like to send up any fixes or changes:

1. Fork it ( https://github.com/chef-partners/omnibus-marketplace/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Test your changes (`cd omnibus-marketplace && bundle install && bundle exec
  rake spec`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request

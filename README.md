chef-marketplace Omnibus project
================================
This project creates full-stack platform-specific packages for
the `chef-marketplace` Chef server add-on.  This add-on extends the Chef server's support for cloud marketplaces.

Shortcuts to All The Things
--------------
1. [Kitchen-Based Build Environment](#kitchen-based-build-environment)
1. [chef-marketplace-ctl](#chef-marketplace-ctl)
  * [chef-marketplace-ctl setup](#setup)
  * [chef-marketplace-ctl reconfigure](#reconfigure)
  * [chef-marketplace-ctl upgrade](#upgrade)
  * [chef-marketplace-ctl test](#test)
1. [Configuration](#configuration)
  * [Example marketplace.rb](#example-config)
1. [Contributing](#contributing)

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

chef-marketplace-ctl
--------------------
### Setup
`chef-marketplace-ctl setup` is a helper command that sets up the Chef server,
Manage, and Reporting with user provided configuration options.

#### Options
`-y, --yes` Agree to the Chef End User License Agreement
`-u USERNAME, --username USERNAME` Admin username
`-p PASSWORD, --password PASSWORD` Admin password
`-f FIRSTNAME, --firstname FIRSTNAME` Admin first name
`-l LASTNAME, --lastname LASTNAME` Admin last name
`-e EMAIL, --email EMAIL` Admin email address
`-o ORGNAME, --org ORGNAME` Default organization name
`-h, --help` Display help information

### Reconfigure
After package installation `chef-marketplace-ctl reconfigure` is run to execute
the embedded configuration recipes.

#### Configuration Options
See the [marketplace.rb](#configuration) configuration for a list of user
configurable attributes.

### Upgrade
`chef-marketplace-ctl upgrade` will upgrade the installed Chef server packages

#### Options
`-y, --yes` Agree to upgrade Chef Server, Marketplace, Reporting and Manage
`-s, --server` Agree to upgrade Chef Server, Reporting and Manage
`-m, --marketplace` Agree to upgrade Marketplace

### Test
`chef-marketplace-ctl test` Perform's unit and functional tests to validate a
succesful package installation and working build. This is run in our development
continuous delivery pipeline to ensure the package works as expected.

Configuration
-------------
The chef-marketplace package supports a number of user supplied customization
options.  Like the majority of Chef products, the syntax is Mixlib::Config based
and the file should be located at `/etc/chef-marketplace/marketplace.rb`

####Example Config
```ruby
# Enable to disable changing the motd
motd['enable'] = true

# Marketplace specific support email address
support['email'] = 'some@email.com'

# Marketplace specific documentation
documentation['url'] = 'http://myorg.com/docs'

# Which role the instanace is supposed to play
role 'server' # or 'analytics'

# Which Cloud Platform the instance is running on
platform 'aws'

# Default user for cloud-init
user 'ec2-user'

# Prevents commands from attempting to use external services like package mirrors
# Changing this setting will disable certain features
disable_outboud_traffic true

# If the instance is going to be bundled/published into the cloud marketplace
# this option will run will enable security recipe to make sure we don't leave
# around sensitive data.
publishing['enabled'] = true

# Enable or disable the reporting auto clean-up
reporting['cron']['enabled'] = true

# Standard crontab expression
reporting['cron']['expression'] = '*/2 * * * *'

# The latest year/month in the reporting database that you want to preserve
reporting['cron']['year'] = 'date +%Y'
reporting['cron']['month'] = 'date +%m'
```

Contributing
------------
Please submit a GitHub issue with any problems you encounter.

Contributions are always welcome!  If you'd like to send up any fixes or changes:

1. Fork it ( https://github.com/chef-partners/omnibus-marketplace/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Test your changes (`cd omnibus-marketplace && bundle install && bundle exec rake`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request

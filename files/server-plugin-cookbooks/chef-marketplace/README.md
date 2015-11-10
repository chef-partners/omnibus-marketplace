We need to hook into the Chef Server's plugin architecture in order to properly configure the chef-marketplace topology.  Currently the plugin architecture requires
that a cookbook with enable/disable recipes must be present.  This is our shim cookbook.

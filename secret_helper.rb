# This module scans the node on which chef-client is running and extracts the Roles and RunList, sorts the data
# to retrieve the cookbooks. It thens sets a temp var (node.run_state) that contains the secret associated
# with the cookbook if it's present on the chef server.
# You can then use the encrypted data bag in your recipes like so :
# dtbg = data_bag_item('yp_elk', 'bonjour', node.run_state["secret_yp_elk"])
# var = data_bag_item('dtbg_name', 'dtbg_item', 'node.run_state["secret_ckbk_name"]')
# Then : dtbg['key'] to extract the values
# Maintainer : Samuel Ross (samuel.ross@cgi.com)
# Copyright (c) 2019 Samuel Ross, All Rights Reserved.

module YpSys
  module SecretHelpers

    def get_secrets
      node.run_list.each do |runlist|
        if runlist.role?
          role_obj = Chef::Role.load(runlist.name)
          role_obj.run_list.each do |recipe|
            partition_recipe(recipe.name)
          end
        else
          partition_recipe(runlist.name)
        end
      end
    end

    def partition_recipe(recipename)
      cookbook = recipename.partition("::")[0]
      Chef::Log.info("Trying to gather secret for #{cookbook}")
      node.run_state["secret_#{cookbook}"] = IO.read("/etc/chef/secret/#{cookbook}") if File.exists?("/etc/chef/secret/#{cookbook}")
    end

  end
end


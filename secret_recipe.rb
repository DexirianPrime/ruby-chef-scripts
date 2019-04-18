ssh_private_key "root" do
  source 'chef-vault'
  layout 'simple'
  bag 'ssh_private_keys'
end
directory '/etc/chef/secret' do
  action :create
  mode '0640'
  owner 'root'
  group 'root'
end

# Copy the secret files located on ldcpchef01 to your node @ /etc/chef/secret/secret_name
execute 'rsync' do
  command 'rsync -a -e "ssh -i /root/.ssh/databag_ssh_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" root@chefsrv:/etc/chef/secret/ /etc/chef/secret/'
  ignore_failure true
  sensitive true
end
# Call the Secret Helper with a delay so that the secret files are loaded
ruby_block 'secret' do
  extend YpSys::SecretHelpers
  block do
    only_if ::File.exists?('/root/.ssh/databag_ssh_key')
    get_secrets
  end
end

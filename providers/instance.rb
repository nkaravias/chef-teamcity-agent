Chef::Resource::RemoteFile.send(:include, TeamCity::Agent_helper)
Chef::Resource::Execute.send(:include, TeamCity::Agent_helper)
Chef::Resource::Link.send(:include, TeamCity::Agent_helper)

use_inline_resources

def whyrun_supported?
   true
end

action :install do
  package 'unzip'

  pkg_name = new_resource.install_archive
  local_pkg_path = ::File.join(Chef::Config[:file_cache_path], pkg_name)
  install_path_root = ::File.expand_path('..', new_resource.install_path)

  group new_resource.group do
    action :create
    system true
  end

  user new_resource.user do
    home  new_resource.home
    shell  new_resource.shell
    gid  new_resource.group
    supports manage_home: false
    action  :create
    system true
  end

  directory new_resource.install_path do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
    action :create
  end

  remote_file local_pkg_path do
    source ::File.join(new_resource.server_url, 'update', pkg_name)
    owner new_resource.user
    group new_resource.group
    mode '0644'
    #not_if { tc_agent_installed?(new_resource.install_path, new_resource.install_archive, new_resource.version) }
    not_if { ::File.exist?(new_resource.install_path) }
  end

  execute "Extract #{pkg_name} to #{new_resource.install_path}" do
    cwd Chef::Config[:file_cache_path]
    command "unzip ./#{pkg_name} -d #{new_resource.install_path}; chown #{new_resource.user}:#{new_resource.group} #{new_resource.install_path}/* -R"
    action :run
    #not_if { tc_agent_installed?(new_resource.install_path, new_resource.install_archive, new_resource.version) }
  end
  #download_package(local_pkg_path, ::File.join(new_resource.server_url, 'update', pkg_name))
  #extract_package(pkg_name.match(/^[^\.]*/).to_s, local_pkg_path, install_path_root)
  #create_link(::File.join(install_path_root, "#{pkg_name.match(/^[^\.]*/).to_s}-#{new_resource.version}"), new_resource.install_path)
  #new_resource.updated_by_last_action(true)
end

def download_package(destination, url)
  remote_file destination do
    source url
    owner new_resource.user
    group new_resource.group
    mode '0644'
    #not_if { tc_agent_installed?(new_resource.install_path, new_resource.install_archive, new_resource.version) }
    #not_if { ::File.exist?(
  end
end
=begin
def extract_package(name, source, destination)
  execute "Extract #{name} to #{destination}" do
    cwd destination
    command "unzip #{source} -d ./#{name}-#{new_resource.version}; chown #{new_resource.user}:#{new_resource.group} ./#{name}-#{new_resource.version}*"
    action :run
    not_if { tc_agent_installed?(new_resource.install_path, new_resource.install_archive, new_resource.version) }
  end
end
=end
def create_link(source, target)
  link target do
    to source
    owner new_resource.user
    group new_resource.group
    not_if { tc_agent_installed?(new_resource.install_path, new_resource.install_archive, new_resource.version) }
  end
end

def create_directory(path, zk_owner, zk_group)
  directory path do
    owner zk_owner
    group zk_group
    mode '0755'
    recursive true
    action :create
  end
end

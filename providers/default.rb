use_inline_resources

def whyrun_supported?
  true
end

action :install do
  package 'unzip'

  # Use a simple include on Chef 12
  run_context.include_recipe 'java' unless new_resource.use_default_java == false

  pkg_name = new_resource.install_archive
  local_pkg_path = ::File.join(Chef::Config[:file_cache_path], pkg_name)

  user "Teamcity agent user" do
    comment "TeamCity user"
    username new_resource.user
    system false
    supports { :manage_home }
    home new_resource.home
    shell new_resource.shell
    group "users"
  end

  group "Teamcity agent group" do
    group_name new_resource.group
    members new_resource.user
    append true
  end

  remote_file "Download installer from #{new_resource.server_url}" do
    path local_pkg_path
    source ::File.join(new_resource.server_url, 'update', pkg_name)
    owner new_resource.user
    group new_resource.group
    mode '0644'
    not_if { ::File.exist?(new_resource.install_path) }
  end

  execute "Extract #{pkg_name} to #{new_resource.install_path}" do
    cwd Chef::Config[:file_cache_path]
    command "unzip ./#{pkg_name} -d #{new_resource.install_path}; chown #{new_resource.user}:#{new_resource.group} #{new_resource.install_path}/* -R"
    action :run
    not_if { ::File.exist?(new_resource.install_path) }
  end

  directory "Create directory path for #{new_resource.install_path}" do
    path new_resource.install_path
    owner new_resource.user
    group new_resource.group
    mode 0755
    recursive true
    action :create
  end
end

action :configure do
  template ::File.join('/etc/init.d', new_resource.service_name) do
    source 'etc/initd.erb'
    cookbook 'teamcity_agent'
    mode 0755
    variables(tc_agent_home: new_resource.install_path, tc_user: new_resource.user, 
tc_service_name: new_resource.service_name)
  end

  agent_properties = ::File.join(new_resource.install_path, 'conf/buildAgent.properties')
  auth_token_string = 'authorizationToken='
  if ::File.exist?(agent_properties)
    agent_properties_content = IO.read(agent_properties)
    if /^#{auth_token_string}.*$/.match(agent_properties_content).nil?
      auth_token = auth_token_string
    else
      auth_token = /^#{auth_token_string}.*$/.match(agent_properties_content)
    end
  else
    auth_token = auth_token_string
  end

  file ::File.join(new_resource.install_path, 'bin', 'agent.sh') do
    owner new_resource.user
    group new_resource.group
    mode 0755
  end

  template "Creating buildAgent.properties for #{auth_token}" do
    path agent_properties
    source 'etc/agent.properties.erb'
    cookbook 'teamcity_agent'
    owner new_resource.user
    group new_resource.group
    mode 0644
    action :create
    helpers(TeamCity::AgentHelper)
    variables(server_url: new_resource.server_url, auth_token: auth_token, 
custom_agent_properties: new_resource.custom_agent_properties)
    notifies :restart, "service[#{new_resource.service_name}]", :delayed
  end

  service new_resource.service_name do
    action [:enable]
  end
end

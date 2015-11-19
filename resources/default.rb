actions :install, :configure
default_action :install

attribute :user, kind_of: String, default: 'teamcity'
attribute :group, kind_of: String, default: 'teamcity'
attribute :shell, kind_of: String, default: '/bin/bash'
attribute :home, kind_of: String, default: '/scratch/teamcity'
attribute :install_path, kind_of: String, default: '/var/tcbuildagent'
attribute :install_archive, kind_of: String, default: 'buildAgent.zip'
attribute :server_url, kind_of: String, required: true
attribute :version, kind_of: String, default: '8.1.4'
attribute :service_name, kind_of: String, default: 'tcbuildagent'
attribute :use_default_java, kind_of: [TrueClass, FalseClass], default: true

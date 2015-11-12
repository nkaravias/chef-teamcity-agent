module TeamCity
  module Agent_helper
    
    def tc_agent_installed?(install_path, archive, version)
      # does the symlink exist 
      return false unless File.symlink?(install_path)
      # does the install_path symlink point to a file that looks like archive-version 
      symlink_source = File.basename(File.readlink(install_path))
      return false unless symlink_source == "#{archive.match(/^[^\.]*/).to_s}-#{version}"
      # does install_path/bin/agent.jar exist
      return false unless ::File.exist?(::File.join(install_path,'lib','agent.jar'))
      true
    end

  end
end


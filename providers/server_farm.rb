
include Chef::Mixin::ShellOut


def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "Server Farm #{ @new_resource } already exists - not recreating."
  else
#    Chef::Log.info "In Create"
    converge_by("Creating Server Farm #{ @new_resource.name }") do
      Chef::Log.info "Add Web Farm #{@new_resource.name }==================================="
      create_server_farm @new_resource.name  
    end
  end

  #servers
  @current_resource.servers.each do |server_name|
    Che::Log.info "-----------> #{server_name}   ---------------"
  end

end

action :delete do
  if @current_resource.exists
    converge_by("Delete server farm #{ @new_resource.name }") do
      Chef::Log.info "Deleting Server Farm #{ @new_resource }"
      delete_server_farm ( @new_resource.name)
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end

def load_current_resource
  @appcmd = "#{ENV['systemdrive']}\\windows\\sysnative\\inetsrv\\appcmd.exe"
  @current_resource = Chef::Resource::IisArrServerFarm.new(@new_resource.name)
  @current_resource.servers(@new_resource.servers)
  @current_resource.health_test_url(@new_resource.health_test_url)

  if server_farm_exists?(@current_resource)
    @current_resource.exists = true
  end
end


private

#def create_firewall_rule( newresource )
#  if rule_exists?( newresource) 
#    Chef::Log.info "Firewall rule exists: #{newresource.name} -- Skipping create..."
#  
#  else
#     cmd_str = "netsh advfirewall firewall add rule name=\"#{new_resource.name}\" " 
#     cmd_str += "description=\"#{newresource.description}\" " if  newresource.description
#     cmd_str += "action=\"#{newresource.fw_action}\" " if newresource.fw_action
#     cmd_str += "localip=\"#{newresource.local_ip}\" " if newresource.local_ip
#     cmd_str += "localport=\"#{newresource.local_port}\" " if newresource.local_port
#     cmd_str += "remoteip=\"#{newresource.remote_ip}\" " if newresource.remote_ip
#     cmd_str += "remoteport=\"#{newresource.remote_port}\" " if newresource.remote_port
#     cmd_str += "dir=\"#{newresource.dir}\" " if newresource.dir
#     cmd_str += "protocol=\"#{newresource.protocol}\" " if newresource.protocol
#     cmd_str += "profile=\"#{newresource.profile}\" " if newresource.profile
#     cmd_str += "service=\"#{newresource.service}\" " if newresource.service
#     cmd_str += "interfacetype=\"#{newresource.interface_type}\" " if newresource.interface_type
#     cmd_str += "program=\"#{newresource.program}\" " if newresource.program
#    Chef::Log.debug "Creating firewall rule with command: #{cmd_str}"
#    execute "netsh advfirewall" do
#      command cmd_str
#    end
#  end
#
#end
#
#def delete_firewall_rule( newresource)
#  if rule_exists?( newresource) 
#    cmd_str = "netsh advfirewall firewall delete rule name=\"#{newresource.name}\" " 
#    cmd_str += "dir=\"#{newresource.dir}\" " if newresource.dir
#    cmd_str += "profile=\"#{newresource.profile}\" " if newresource.profile
#    cmd_str += "program=\"#{newresource.program}\" " if newresource.program
#    cmd_str += "service=\"#{newresource.service}\" " if newresource.service
#    cmd_str += "localip=\"#{newresource.local_ip}\" " if newresource.local_ip
#    cmd_str += "localport=\"#{newresource.local_port}\" " if newresource.local_port
#    cmd_str += "remoteip=\"#{newresource.remote_ip}\" " if newresource.remote_ip
#    cmd_str += "remoteport=\"#{newresource.remote_port}\" " if newresource.remote_port
#    cmd_str += "protocol=\"#{newresource.protocol}\" " if newresource.protocol
#
#    Chef::Log.debug "Removing firewall rule with command: #{cmd_str}"
#    execute "netsh advfirewall" do
#      command cmd_str
#    end
#  else
#    Chef::Log.info "Firewall rule doesnt exist: #{newresource.name} -- Skipping delete..."
#  end
#end
#
def create_server_farm(farm_name)
  execute "#{@appcmd} set config -section:webFarms /+\"[name='#{farm_name}']\" /commit:apphost" do
    action  :run
  end
end

def delete_server_farm(farm_name)
  execute "#{@appcmd} set config -section:webFarms /-\"[name='#{farm_name}']\" /commit:apphost" do
    action  :run
  end
end

def server_farm_exists?( new_resource)
  cmd_str = "#{@appcmd} list config -section:webFarms"
  Chef::Log.debug "Checking existence of ARR server farm with command: #{cmd_str}"

  cmd = shell_out("#{cmd_str}", { :returns => [0] })
  if (cmd.stderr.empty? && (cmd.stdout =~ /webFarm\s+Name=\"#{Regexp.escape(new_resource.name)}\"/i))
    Chef::Log.debug "Server farm exists: #{new_resource.name}"
    return true
  end

  Chef::Log.debug "Server Farm not found: #{new_resource.name}"
  return false
end



include Chef::Mixin::ShellOut


def whyrun_supported?
  true
end

use_inline_resources


action :create do
  farm_name = @new_resource.name

  if @current_resource.exists
    Chef::Log.info "Server Farm #{ farm_name } already exists - not recreating."
  else
    converge_by("Creating Server Farm #{ farm_name }") do
      Chef::Log.info "Add Web Farm #{farm_name }==================================="
      create_server_farm farm_name  
    end
  end

  new_list = @new_resource.servers || []
  cur_list = @current_resource.servers || []

  servers_to_add = new_list - cur_list
  servers_to_remove =  cur_list - new_list 
  servers_unchanged = cur_list - servers_to_add - servers_to_remove

  if servers_to_add 
    servers_to_add.each do |s| 
      converge_by("Adding #{s} to list of addresses in server farm #{farm_name}") do
        Chef::Log.info "Adding #{s} to list of addresses in server farm #{farm_name}"
        add_server_to_farm farm_name, s
      end
    end
  end 
  if servers_to_remove 
    servers_to_remove.each do |s| 
      converge_by("Removing #{s} from list of addresses in server farm #{farm_name}") do
        Chef::Log.info "Removing #{s} from list of addresses in server farm #{farm_name}"
        remove_server_from_farm farm_name, s
      end
    end
  end 
  #if servers_unchanged   
  #  servers_unchanged .each {|s| Chef::Log.info " No Change   !!!!!!!!!! #{s} !!!!!!!!!!"}
  #end 
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
  #@current_resource.servers(@new_resource.servers)
  #@current_resource.health_test_url(@new_resource.health_test_url)

  if server_farm_exists?(@current_resource)
    @current_resource.exists = true
    @current_resource.servers( load_farm_server_list (@current_resource.name) )
  end
end


private

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

def add_server_to_farm(farm_name, server_name)
  execute "#{@appcmd} set config -section:webFarms /+\"[name='#{farm_name}'].[address='#{server_name}',enabled='true']\" /commit:apphost" do
    action  :run
  end
end

def remove_server_from_farm(farm_name, server_name)
  execute "#{@appcmd} set config -section:webFarms /-\"[name='#{farm_name}'].[address='#{server_name}']\" /commit:apphost" do
    action  :run
  end
end


def load_farm_server_list( farm_name)
  cmd_str = "#{@appcmd} list config -section:webFarms"
  Chef::Log.debug "Checking existence of ARR server farm with command: #{cmd_str}"

  cmd = shell_out("#{cmd_str}", { :returns => [0] })
  servers = cmd.stdout.scan( /<server\s+address="([^"]+)"/m  ).flatten

  return servers || []

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


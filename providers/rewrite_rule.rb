

include Chef::Mixin::ShellOut


def whyrun_supported?
  true
end

use_inline_resources


action :create do
  rule_name = @new_resource.name

  if @current_resource.exists
    Chef::Log.info "rewrite rule #{ rule_name } already exists - not recreating."

    #modify if fields have changed
    converge_url 
    converge_stop_processing 
    converge_pattern 
    converge_pattern_syntax 
  else
    converge_by("Creating rewrite rule #{ rule_name }") do
      Chef::Log.info "Add rewrite rule #{rule_name }==================================="
      create_rewrite_rule( @new_resource.name,  @new_resource.pattern_syntax,  @new_resource.pattern,  @new_resource.stop_processing,  @new_resource.url)
      @new_resource.updated_by_last_action(true)
    end
  end

end

action :delete do
  if @current_resource.exists
    converge_by("Delete rewrite rule #{ @new_resource.name }") do
      Chef::Log.info "Deleting rewrite rule #{ @new_resource }"
      delete_rewrite_rule ( @new_resource.name)
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end

def load_current_resource
  #Require nokogiri here to delay loading until after recipe has run to install it
  require 'nokogiri'
  
  @appcmd = "#{ENV['systemdrive']}\\windows\\sysnative\\inetsrv\\appcmd.exe"

  @current_resource = Chef::Resource::IisArrRewriteRule.new(@new_resource.name)
  
  if rewrite_rule_exists?(@current_resource)
    @current_resource.exists = true
    #get the current config
    cmd_str = "#{@appcmd} list config -section:system.webServer/rewrite/globalRules"
    cmd = shell_out("#{cmd_str}", { :returns => [0] })
    xml_doc = Nokogiri::XML(cmd.stdout)
    rule_node = xml_doc.xpath("//rule[@name='#{@new_resource.name}']")
    unless rule_node.empty?
      @current_resource.pattern_syntax(rule_node.attr("patternSyntax").to_s)    
      @current_resource.stop_processing(!!rule_node.attr("stopProcessing").to_s)  
    
      @current_resource.pattern( rule_node.xpath("//match").attr("url").to_s )  
      @current_resource.url( rule_node.xpath("//action[@type='Rewrite']").attr("url").to_s )  

      #Chef::Log.info "------------------------------------------------------------------"
      #Chef::Log.info "      @current_resource.name: #{@current_resource.name}"
      #Chef::Log.info "      @current_resource.pattern: #{@current_resource.pattern}"
      #Chef::Log.info "      @current_resource.pattern_syntax: #{@current_resource.pattern_syntax}"
      #Chef::Log.info "      @current_resource.url: #{@current_resource.url}"
      #Chef::Log.info "      @current_resource.stop_processing: #{@current_resource.stop_processing}"
      #Chef::Log.info "------------------------------------------------------------------"
    end
  end
end


private

def converge_url 
    if @new_resource.url != @current_resource.url
      converge_by("new url - changing from #{@current_resource.url} to #{@new_resource.url}") do
        #update it
        #@new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.debug "url unchanged - nothing to do (#{@new_resource.url} = #{@current_resource.url})"
    end 
end
def converge_stop_processing 
    if @new_resource.stop_processing != @current_resource.stop_processing
      converge_by("new stop_processing - changing from #{@current_resource.stop_processing} to #{@new_resource.stop_processing}") do
        #update it
        #@new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.debug "stop_processing unchanged - nothing to do (#{@new_resource.stop_processing} = #{@current_resource.stop_processing})"
    end 
end
def converge_pattern 
    if @new_resource.pattern != @current_resource.pattern
      converge_by("new pattern - changing from #{@current_resource.pattern} to #{@new_resource.pattern}") do
        #update it
        #@new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.debug "pattern unchanged - nothing to do (#{@new_resource.pattern} = #{@current_resource.pattern})"
    end 
end
def converge_pattern_syntax 
    if @new_resource.pattern_syntax != @current_resource.pattern_syntax
      converge_by("new pattern_syntax - changing from #{@current_resource.pattern_syntax} to #{@new_resource.pattern_syntax}") do
        #update it
        #@new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.debug "pattern_syntax unchanged - nothing to do (#{@new_resource.pattern_syntax} = #{@current_resource.pattern_syntax})"
    end 
end

def create_rewrite_rule(rule_name, pattern_syntax, pattern, stop_processing, url)
  execute "#{@appcmd} set config -section:system.webServer/rewrite/globalRules /+\"[name='#{rule_name}',patternSyntax='#{pattern_syntax}',stopProcessing='#{stop_processing.to_s}']\" /commit:apphost" do
    action  :run
  end
  
  execute "#{@appcmd} set config -section:system.webServer/rewrite/globalRules /\"[name='#{rule_name}'].match.url:#{pattern}\" /commit:apphost" do
    action  :run
  end
  
  execute "#{@appcmd} set config -section:system.webServer/rewrite/globalRules /\"[name='#{rule_name}'].action.type:Rewrite\" /\"[name='#{rule_name}'].action.url:#{url}\" /commit:apphost" do
    action  :run
  end

end

def delete_rewrite_rule(rule_name)
  execute "#{@appcmd} set config -section:system.webServer/rewrite/globalRules /-\"[name='#{rule_name}']\" /commit:apphost" do
    action  :run
  end
end



def rewrite_rule_exists?( new_resource)
  cmd_str = "#{@appcmd} list config -section:system.webServer/rewrite/globalRules"
  Chef::Log.debug "Checking existence of ARR server rule with command: #{cmd_str}"

  cmd = shell_out("#{cmd_str}", { :returns => [0] })
  if (cmd.stderr.empty? && (cmd.stdout =~ /<rule\s+name=\"#{Regexp.escape(new_resource.name)}\"/i))
    Chef::Log.debug "rewrite rule exists: #{new_resource.name}"
    return true
  end

  Chef::Log.debug "rewrite rule not found: #{new_resource.name}"
  return false
end


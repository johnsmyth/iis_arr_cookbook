require File.expand_path('../spec_helper.rb', __FILE__)

describe_recipe  'iis_arr::test_recipe_test.rb' do
  include Helpers::Iis_arr
  include Chef::Mixin::ShellOut
  require 'nokogiri'

  #Verify that ARR is installed
  it 'has ARR application installed' do
  	appcmd = 'C:\\windows\\sysnative\\inetsrv\appcmd.exe'
  	result = "#{appcmd} list modules \"ApplicationRequestRouting\""
  	refute_nil(result)
  end

  it 'adds the server farms' do
  	appcmd = 'C:\\windows\\sysnative\\inetsrv\appcmd.exe'
    cmd_str = "#{appcmd} list config -section:webFarms"
    %w[ TestFarm TestFarm6].each do |server_farm|
      cmd = shell_out("#{cmd_str}", { :returns => [0] })
      cmd.stdout.must_match /webFarm\s+Name=\"#{Regexp.escape(server_farm)}\"/i
    end
  end

  it 'deletes the server farms' do
  	appcmd = 'C:\\windows\\sysnative\\inetsrv\appcmd.exe'
    cmd_str = "#{appcmd} list config -section:webFarms"
    %w[ TestFarm-delete ].each do |server_farm|
      cmd = shell_out("#{cmd_str}", { :returns => [0] })
      cmd.stdout.wont_match /webFarm\s+Name=\"#{Regexp.escape(server_farm)}\"/i
    end
  end

  it 'modifies the server list correctly for TestFarm' do
  	appcmd = 'C:\\windows\\sysnative\\inetsrv\appcmd.exe'
    cmd_str = "#{appcmd} list config -section:webFarms"
    cmd = shell_out("#{cmd_str}", { :returns => [0] })
    xml_doc = Nokogiri::XML(cmd.stdout)
    servers = []
    xml_doc.xpath("//webFarm[@name='TestFarm']/server").each { |s| servers.push s.attr("address") }
    servers.must_include "server1"
    servers.must_include "server2"
    servers.wont_include "serverx"
    servers.wont_include "servery"
    servers.wont_include "192.168.0.1"
    servers.wont_include "ADDME"
  end

  it 'modifies the server list correctly for TestFarm6' do
  	appcmd = 'C:\\windows\\sysnative\\inetsrv\appcmd.exe'
    cmd_str = "#{appcmd} list config -section:webFarms"
    cmd = shell_out("#{cmd_str}", { :returns => [0] })
    xml_doc = Nokogiri::XML(cmd.stdout)
    servers = []
    xml_doc.xpath("//webFarm[@name='TestFarm6']/server").each { |s| servers.push s.attr("address") }
    servers.must_include "serverx"
    servers.must_include "servery"
    servers.wont_include "server1"
    servers.wont_include "server2"
    servers.wont_include "192.168.0.1"
    servers.wont_include "ADDME"
  end

  it 'sets the health check url' do
  	appcmd = 'C:\\windows\\sysnative\\inetsrv\appcmd.exe'
    cmd_str = "#{appcmd} list config -section:webFarms"
    cmd = shell_out("#{cmd_str}", { :returns => [0] })
    xml_doc = Nokogiri::XML(cmd.stdout)
  
    url_node = xml_doc.xpath("//webFarm[@name='TestFarm6']/applicationRequestRouting/healthCheck")
    url_node.attr("url").to_s.must_equal 'http://www.healthcheck.com'
  end
  
end

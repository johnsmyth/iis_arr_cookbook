#
# Cookbook Name:: iis_arr
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

require 'chef/win32/version'
windows_version = Chef::ReservedNames::Win32::Version.new

include_recipe 'webpi'

# Add IIS roles
# ORDER IS IMPORTANT IN MOST CASES
features = [
	'IIS-WebServerRole',
	'IIS-WebServer',
	'IIS-CommonHttpFeatures',
	'IIS-HealthAndDiagnostics',
	'IIS-HttpLogging',
	'IIS-RequestMonitor',
	'IIS-HttpTracing',
	'IIS-WebServerManagementTools'
]

features.push('IIS-ManagementConsole') if !windows_version.core?

features.each { |feature| 
	windows_feature feature do
    	action :install
  	end
}

# Install ARR v 3.0
webpi_product 'ARRv3_0' do
  accept_eula true
  action :install
end

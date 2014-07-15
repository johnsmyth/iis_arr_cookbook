require File.expand_path('../spec_helper.rb', __FILE__)

describe_recipe  'iis_arr::_default_test.rb' do
  include Helpers::Iis_arr

  # Verify that the Web Service is running
  it 'W3SVC should be running as a service' do
  	service('W3SVC').must_be_running
  end

  # Verify that the web service boots on startup
  it 'W3SVC boots on startup' do
  	service('W3SVC').must_be_enabled
  end

  #Verify that ARR is installed
  it 'has ARR application installed' do
  	app_cmd = 'C:\\windows\\sysnative\\inetsrv\appcmd.exe'
  	result = "#{app_cmd} list modules \"ApplicationRequestRouting\""
  	refute_nil(result)
  end

end

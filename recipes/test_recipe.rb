include_recipe "iis_arr::default"

iis_arr_server_farm "TestFarm1" do
  name "TestFarm-delete"
  action :create
end

iis_arr_server_farm "TestFarm3" do
  name "TestFarm-delete"
  action :delete
end

iis_arr_server_farm "TestFarm2" do
  name "TestFarm"
  action :create
end


iis_arr_server_farm "TestFarm4" do
  name "TestFarm"
  action :delete
end

iis_arr_server_farm "TestFarm5" do
  name "TestFarm"
  action :create
  servers ["server1", "server2", "192.168.0.1"]
end

iis_arr_server_farm "TestFarmy" do
  name "TestFarm"
  action :create
  servers ["server1", "server2", "192.168.0.1", "ADDME"]
  health_check_url 'http://www.healthcheck-save.com'
end

iis_arr_server_farm "TestFarmx" do
  name "TestFarm"
  action :create
  servers ["server1", "server2" ]
end



iis_arr_server_farm "TestFarm6" do
  action :create
  servers ["serverx", "servery" ]
  health_check_url 'http://www.healthcheck.com'
end

iis_arr_rewrite_rule "ARR_TestFarm6_TestRule1" do
  pattern  '(/*)([^/]+)\/(/*)(0012)(.)?.*\/()(.)?.*'
  pattern_syntax 'ECMAScript'
  url 'http://TestFarm6/{R:0}'
  stop_processing true
end

iis_arr_rewrite_rule "ARR_TestFarm6_TestRule1" do
  pattern  'CHANGED Pattern'
  pattern_syntax 'Wildcard'
  url 'http://New_URL'
  stop_processing false
end

iis_arr_rewrite_rule "TestFarm6_TestRule2" do
  pattern  '(/*)([^/]+)\/(/*)(0012)(.)?.*\/()(.)?.*'
  pattern_syntax 'ECMAScript'
  url 'http://TestFarm6/{R:0}'
end

iis_arr_rewrite_rule "TestFarm6_TestRule3" do
  pattern  '(/*)([^/]+)\/(/*)(0012)(.)?.*\/()(.)?.*'
  pattern_syntax 'ECMAScript'
  url 'http://TestFarm6/{R:0}'
end

iis_arr_rewrite_rule "TestFarm6_TestRule3" do
  action :delete
end

include_recipe "iis_arr::default"

iis_arr_server_farm "TestFarm1" do
  name "TestFarm"
  action :create
end

iis_arr_server_farm "TestFarm2" do
  name "TestFarm"
  action :create
end

iis_arr_server_farm "TestFarm3" do
  name "TestFarm"
  action :delete
end
iis_arr_server_farm "TestFarm4" do
  name "TestFarm"
  action :delete
end

iis_arr_server_farm "TestFarm5" do
  name "TestFarm"
  action :create
end
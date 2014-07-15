
actions :create, :delete
default_action :create

#attribute :resource_name, :name_attribute => true, :kind_of => String, :required => true 
attribute :name, :name_attribute => true, :kind_of => String, :required => true 
attribute :servers,  :kind_of => Array, :required => true 
attribute :health_test_url, :kind_of => String

attr_accessor :exists

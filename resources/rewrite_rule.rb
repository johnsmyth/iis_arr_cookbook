actions :create, :delete
default_action :create

attribute :name, :name_attribute => true, :kind_of => String, :required => true 
attribute :pattern, :kind_of => String
attribute :pattern_syntax, :kind_of => String
attribute :url, :kind_of => String
attribute :stop_processing, :kind_of => [TrueClass, FalseClass], :default => false

attr_accessor :exists

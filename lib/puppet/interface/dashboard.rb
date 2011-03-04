#require 'puppet/feature/rails'
#require 'node_class'
require 'puppet/interface'
require 'puppet/interface/parser'
require 'puppet/tools/dashboard'
include Puppet::Tools::Dashboard
Puppet::Interface.new(:dashboard) do
  action(:import_classes) do 
    raise 'Must pass dashboard path' unless options[:dashboard_path]
    interface = Puppet::Interface.interface(:parser)
    interface.options=options
    klasses = interface.get_classes
    import_classes_to_dashboard(options[:dashboard_path], klasses)
  end
end

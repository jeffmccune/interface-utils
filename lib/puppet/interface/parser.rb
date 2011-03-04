require 'puppet/interface/indirector'
require 'puppet/interface/resource_type'
require 'puppet/tools/module'
require 'puppet/tools/node'
require 'find'
include Puppet::Tools::Module
# parses existing 
Puppet::Interface.new(:parser) do

  # return all nodes from a manifest
  action(:get_nodes) do
    get_resources_of_type(:node)
  end

  # retuns an array with the names of all nodes
  action(:get_node_names) do
    get_nodes.collect do |node|
      node.name
    end
  end

  # get back the resources for all classes in a modulepath
  action(:get_classes) do 
    @modulepath = set_modulepath(options[:modulepath])
    get_code(@modulepath)[:manifests].collect do |file|
      Puppet[:manifest]=file
      get_resources_of_type(:hostclass)
    end.flatten
  end

  action(:get_class_names) do
    code = get_classes(@modulepath).collect do |klass|
      klass.name
    end
  end

  # thinking about how to parser out resources
  #action(:get_resources) do
  #  @modulepath = set_modulepath(options[:modulepath])
  #  get_all_resources 
  #end
end

require 'puppet/interface'
# helper methods for nodes
module Puppet::Tools
  module Node
    # get the existing nodes that have been serialized in yaml
    # always returns an array
    def get_nodes(node_name, terminus='yaml')
      interface = Puppet::Interface.interface(:node)
      interface.set_terminus(terminus)
      if node_name.include?('*')
        interface.search(node_name)
      else
        [interface.find(node_name)]
      end
    end
  end
end

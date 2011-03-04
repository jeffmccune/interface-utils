# This application is for catalog analysis
# This application should run as a client
require 'puppet/application/interface_base'
require 'yaml'

class Puppet::Application::Parser < Puppet::Application::InterfaceBase
  option('--outputdir DIR') do |args|
    @options[:outputdir] = args
  end
  def render(results)
    case verb
      when 'get_nodes' then
        file_hash = {}
        results.each do |resource|
          #puts resource.class
          file_hash[resource.file] ||= []
          file_hash[resource.file].push(resource.name)
        end
        file_hash.to_yaml
      when 'get_classes' then
        file_hash = {}
        results.each do |resource|
          args = {}
          resource.arguments.each do |arg, value|
            if value.class == Puppet::Parser::AST::String or
               value.class == Puppet::Parser::AST::Boolean or
               value.class == Puppet::Parser::AST::Undef
              args[arg]=value.value
            else
              args[arg]=value
            end
          end
          file_hash[resource.name]=args
        end
        file_hash.to_yaml
      when 'get_node_names', 'get_class_names' then
        results.sort.inject('') do |str, node| str << node << "\n" end
    end
  end
end

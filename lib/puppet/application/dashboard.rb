require 'puppet/application/interface_base'
require 'yaml'
class Puppet::Application::Dashboard < Puppet::Application::InterfaceBase
  option('--dashboard_path PATH') do |args|
    @options[:dashboard_path]=args 
  end
  def render(result) 
    result.to_yaml
  end
end

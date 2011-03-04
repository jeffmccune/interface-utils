require 'puppet/interface'
require 'puppet/tools/module'
require 'puppet/tools/compile'
require 'find'
include Puppet::Tools::Module
include Puppet::Tools::Compile
# inherits from interface b/c they is no indirector
Puppet::Interface.new(:test) do

  # check for any tests that may be missing
  action(:check_tests) do |*args|
    @modulepath = set_modulepath(options[:modulepath])
    code = get_code(@modulepath, :get_tests => true)[:untested]
  end

  # compile all tests
  action(:compile_tests) do |*args|
    @modulepath = set_modulepath(options[:modulepath])
    @run_noop = options[:run_noop]
    code = get_code(@modulepath, :get_tests => true)
    results = compile_module_tests(code[:tests], @run_noop)
  end
end

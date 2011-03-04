require 'find'
# helper methods for setting up modules
module Puppet::Tools
  module Module
    #  given a modulepath, returns all of the manifests and test manifests
    #  and manifests without corresponding tests
    def get_code(modulepath, opts={})
      get_tests = opts[:get_tests]
      code = {:tests => [], :untested => [], :manifests => []}
      tests, manifests = [],[]
      modulepath.split(':').each do |path|
        path.gsub!(/\/$/, '')
        Puppet.info("Searching modulepath: #{path}")
        # TODO - this does not find symlinks
        Find.find(path) do |file|
          if get_tests and file =~ /#{path}\/(\S+)\/tests\/(\S+.pp)$/
            code[:tests].push file
            tests.push "#{$1}-#{$2.gsub('/', '-')}"
          elsif file =~ /#{path}\/(\S+)\/manifests\/(\S+.pp)$/
            code[:manifests].push file
            manifests.push "#{$1}-#{$2.gsub('/', '-')}"
          end
        end
      end
      code[:untested] = manifests-tests if get_tests
      code
    end

    # allows modulepath to be overridden from the command lint
    # NOTE - I am not sure if this is required
    def set_modulepath(modulepath)
      @env = Puppet::Node::Environment.new(Puppet[:environment])
      Puppet[:modulepath] = modulepath || @env[:modulepath]
    end

    def get_resources_of_type(type)
      @types_interface = Puppet::Interface::Resource_type
      @types_interface.search('*').select do |resource|
        resource.type == type.to_sym
      end
    end
    def get_all_resources
      @types_interface = Puppet::Interface::Resource_type
      @types_interface.search('*').inspect
    end
  end
end

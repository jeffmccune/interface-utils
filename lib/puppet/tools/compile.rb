require 'puppet/interface'
module Puppet::Tools
  module Compile 
  # take a list of manifests and compile catalogs
  # NOTE - this assumes that there are no '-' in the modulename
    def compile_module_tests(testfiles, run_noop=false, noop_exclude=[])
      # TODO - I should be able to pick any fact cache
      results = {}
      testfiles.each do |test|
        Puppet[:manifest]=test
        # convert manifests into a readable minimal name that is unique
        node_name = test.gsub('/', '-')
        results[node_name] = {}
        facts = Puppet::Interface.interface(:facts).find(node_name)
        node = Puppet::Node.new(node_name)#.merge(facts.values)
        node.merge(facts.values)
        catalog = compile_from_node(node, :ignore_cache=>true)
        #require 'ruby-debug';debugger
        noop_status = nil
        catalog = catalog || :failed_to_compile
        results[node_name]['catalog'] = catalog
        puts node_name
        if run_noop and catalog != :failed_to_compile
          # TODO - I should be saving the status that is returned
          results[node_name]['results'] = noop_run(catalog)
        else
          # return failed if catalog is nil
        end
      end
      results
    end

    # given a catalog, run it in noop mode
    def noop_run(catalog)
      begin
        catalog = catalog.to_ral
        Puppet[:noop] = true
        require 'puppet/configurer'
        configurer = Puppet::Configurer.new
        Puppet[:pluginsync] = false
        status = configurer.run(:catalog => catalog)
      rescue
        Puppet.err("Exception when noop running catalog #{$!}")
        :failed_to_run
      end
    end
    # compile a catalog from a node's yaml
    def compile_from_node(node, opts={})
      begin
        # interface = Puppet::Interface.interface(:catalog).new()
        # TODO - I need to pass a node so that I can set the environment
        # caching to yaml after compilation, but ignoring the cache
        cat_interface = Puppet::Interface.interface(:catalog)
        cat_interface.indirection.cache_class = :yaml
        catalog = nil
        if node.class == Puppet::Node
          catalog = cat_interface.find(node.name, :use_node => node, :ignore_cache=>true)
        else
          catalog = cat_interface.find(node, :ignore_cache=>true)
        end
        Puppet.debug "Compile test results: #{catalog.render(:pson)}"
        catalog
      rescue
        Puppet.warning("Node #{node} could not compile: #{$!}")
        return false
      end
   end
  end
end

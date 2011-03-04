module Puppet::Tools
  module Dashboard
       # import_classes_to_dashboard(klasses)
    def import_classes_to_dashboard(dashboard_path, klasses)
      Dir.chdir(dashboard_path) do
        klasses.collect do |klass|
          stdout = `rake nodeclass:add name=#{klass.name}`  
          "adding class:#{klass.name}:#{stdout}"
        end
      end
    end
  end
end

require 'puppet/application/interface_base'
require 'yaml'

class Puppet::Application::Test < Puppet::Application::InterfaceBase
  run_mode :master
  option('--modulepath PATH') do |args|
    options[:modulepath]=args
  end
  option('--outputdir DIR') do |args|
    options[:outputdir]=args
  end
  option('--run_noop')
  # reder is also setting the return code
  def render(results) 
    case verb
      when 'check_tests' then 
        starting_str = "The following manifests are missing tests\n"
        results.inject(starting_str) do |str, element| 
          exit_code = 1
          str << "#{element}\n" 
        end
      when 'compile_tests' then
        transformed_results = {
          'failed_to_compile' => [],
          'compiled' => []
        }
        results.each do |k,v|
          if v['catalog'] == :failed_to_compile
            transformed_results['failed_to_compile'].push(k)
          else
            transformed_results['compiled'].push(k)
            if @options[:run_noop]
              if v['results'] == :failed_to_run
                transformed_results[:failed_to_run] ||= []
                transformed_results[:failed_to_run].push(k)
              end
              transformed_results[v['results'].status] ||= []
              transformed_results[v['results'].status].push(k) 
            end
          end
        end
        # TODO - I could store catalogs at outputdir
        # if either of these keys exist, return non-zero
        if transformed_results[:failed_to_compile] or
           transformed_results[:failed]
          @exit_code=1
        end
        transformed_results.to_yaml
    end
  end
end

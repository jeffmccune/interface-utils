require File.join(File.dirname(__FILE__), '../../find_spec_utils.rb')
require 'puppet'
require 'puppet/tools/compile'

include Puppet::Tools::Compile

describe 'Puppet::Tools::Compile' do
  before :each do
    @yamldir=tmpdir('yamldir')
    @modulepath=tmpdir('module-foo')
    @test_path=File.join(@modulepath, 'tests')
    FileUtils.mkdir_p(@test_path)
    @files = []
    @files.push(File.join(@test_path, 'one.pp'))
    File.open(@files.last, 'w') do |fh| fh.write('notify{foo:}') end
    @files.push(File.join(@test_path, 'two.pp'))
    File.open(@files.last, 'w') do |fh| fh.write('notify{bar:}') end
    FileUtils.mkdir(File.join(@yamldir,'node'))
    Puppet[:yamldir] = @yamldir
    Puppet[:clientyamldir] = @yamldir
    @factobj = Puppet::Node::Facts.new('fact-daddy', {
      'foo' => 'bar'
    })
    @nodeobj = Puppet::Node.new('node-daddy')
    Puppet::Node.terminus_class=:yaml
    @nodeobj.merge({'foo'=>'bar'})
    @nodeobj.save
  end
  describe 'when compiling' do
    before :each do
    end
    it "should be able to compile a catalog for a node" do
      Puppet[:code]='node node-daddy {notify{$foo:}}'
      catalog = compile_from_node('node-daddy')
      catalog.name.should == 'node-daddy'
      catalog.resource('Notify', 'bar').to_s.should == 'Notify[bar]'
    end
    describe 'when compiling tests' do
      it 'should compile manifest file list and return catalogs when successful' do
        compile_module_tests(@files, false)[@files[0].gsub('/', '-')]['catalog'].resource('Notify', 'foo').to_s.should == 'Notify[foo]'#.should_not be_nil
        compile_module_tests(@files, false)[@files[1].gsub('/', '-')]['catalog'].resource('Notify', 'bar').to_s.should == 'Notify[bar]'#.should_not be_nil
      end 
      it 'should stores :failed_to_compile for a failed catalog' do
        File.open(@files.last, 'w') do |fh| fh.write('notifyfoo}') end
        compile_module_tests(@files, false)[@files[0].gsub('/', '-')]['catalog'].resource('Notify', 'foo').to_s.should == 'Notify[foo]'#.should_not be_nil
        compile_module_tests(@files, false)[@files[1].gsub('/', '-')]['catalog'].should == :failed_to_compile#.should_not be_nil
      end
    end
  end
  describe 'when running in noop' do
    #TODO - test this!!!
  end
end

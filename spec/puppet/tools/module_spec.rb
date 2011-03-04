require File.join(File.dirname(__FILE__), '../../find_spec_utils.rb')
require 'puppet'
require 'puppet/tools/module'
include Puppet::Tools::Module


describe 'Puppet::Tools::Module' do
  before :each do
    @modules=['bar', 'foo']
    @modulepaths=[]
    2.times do |i|
      @modulepaths.push(tmpdir('fake_manifests'))
      path=@modulepaths.last
      FileUtils.mkdir_p(File.join(path, @modules[i], "manifests"))
      FileUtils.mkdir_p(File.join(path, @modules[i], "tests"))
      File.open(File.join(path, @modules[i], "manifests/init.pp"), 'w') do |fh|
        fh.write("class #{@modules[i]} { notify{$operatingsystem:}}")
      end
      File.open(File.join(path, @modules[i], "tests/init.pp"), 'w') do |fh|
        fh.write("class {#{@modules[i]}:}")
      end
    end

    @modpath=tmpdir('test_modules')
    FileUtils.mkdir_p(File.join(@modpath, 'fooper', 'manifests', 'dev'))
    FileUtils.mkdir_p(File.join(@modpath, 'fooper', 'tests', 'dev'))
  end
  it 'should warn about any manifests missing tests' do
    get_code(@modpath)[:untested].should == []
    get_code(@modpath)[:manifests].should == []
    get_code(@modpath)[:tests].should == []
  end
  it 'should find untesed' do
    FileUtils.touch(File.join(@modpath, 'fooper', 'manifests', 'dev', 'foo.pp'))
    code = get_code(@modpath, :get_tests => true)
    code[:untested].should == ['fooper-dev-foo.pp']
    code[:manifests].should == ["#{@modpath}/fooper/manifests/dev/foo.pp"]
    code[:tests].should == []
  end
  it 'should get_tested with multiple modulepaths' do
    @modulepaths.each_index do |i|
      FileUtils.touch(File.join(@modulepaths[i], @modules[i], "manifests", 'blah.pp'
))
    end
    code = get_code(@modulepaths.join(':'), :get_tests => true)
    code[:untested].should == ['bar-blah.pp', 'foo-blah.pp']
    code[:tests].should == [
      "#{@modulepaths[0]}/bar/tests/init.pp",
      "#{@modulepaths[1]}/foo/tests/init.pp"]
    code[:manifests].should == 
      ["#{@modulepaths[0]}/bar/manifests/init.pp",
       "#{@modulepaths[0]}/bar/manifests/blah.pp",
       "#{@modulepaths[1]}/foo/manifests/init.pp",
       "#{@modulepaths[1]}/foo/manifests/blah.pp"]
  end

  it 'should not get tests by default' do
    @modulepaths.each_index do |i|
      FileUtils.touch(File.join(@modulepaths[i], @modules[i], "manifests", 'blah.pp'
))
    end
    code = get_code(@modulepaths.join(':'))
    code[:untested].should == []
    code[:tests].should == []
    code[:manifests].should == 
      ["#{@modulepaths[0]}/bar/manifests/init.pp",
       "#{@modulepaths[0]}/bar/manifests/blah.pp",
       "#{@modulepaths[1]}/foo/manifests/init.pp",
       "#{@modulepaths[1]}/foo/manifests/blah.pp"]

  end
  it 'should not care if a modulepath does not exist' do
    dir = File.join(tmpdir('path'), 'floppydoppy')
    get_code(dir).should == {:untested=>[], :manifests=>[], :tests=>[]}
  end
  it 'should correctly find deeper directory paths' do
    @deepdir=tmpdir('fake_manifest')
    FileUtils.mkdir_p(File.join(@deepdir, 'fooper', 'manifests', 'dev'))
    FileUtils.touch(File.join(@deepdir, 'fooper', "manifests/dev/bar.pp"))
    get_code(@deepdir)[:manifests].should == [File.join(@deepdir, 'fooper', "manifests/dev/bar.pp")]
    get_code(@deepdir)[:tests].should == []
    get_code(@deepdir, :get_tests=>true)[:untested].should == ['fooper-dev-bar.pp']

  end
  describe 'when setting module path' do
    it 'should set modulepath' do
      set_modulepath('/tmp/foo')  
      Puppet[:modulepath].should == '/tmp/foo'
    end
    it 'if modulepath is nil, it should default to environments' do
      set_modulepath(nil)  
      Puppet[:modulepath].should == Puppet::Node::Environment.new(Puppet[:environment])[:modulepath]
    end
  end
  describe 'when getting resources' do
    # TODO - test get_resources
  end
end

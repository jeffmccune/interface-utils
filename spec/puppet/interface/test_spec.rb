#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '../../find_spec_utils.rb')
require 'puppet'
require 'puppet/tools/compile'
require 'puppet/application'
require 'puppet/application/test'
require 'yaml'

include Puppet::Tools::Compile

describe 'Puppet::Application::Test' do
  before do
    @tester = Puppet::Interface.interface(:test)
  end

  describe 'when checking tests' do
    describe 'when checking tests' do
      before :each do
        @modpath=tmpdir('test_modules')
        FileUtils.mkdir_p(File.join(@modpath, 'fooper', 'manifests', 'dev'))
        FileUtils.mkdir_p(File.join(@modpath, 'fooper', 'tests', 'dev'))
        FileUtils.touch(File.join(@modpath, 'fooper', 'tests', 'dev', 'a.pp'))
        FileUtils.touch(File.join(@modpath, 'fooper', 'manifests', 'dev', 'a.pp'))
      end
      it 'should identify when there are no missing tests' do
        @tester.options={:modulepath=>@modpath}
        @tester.check_tests(@modpath).should == []
      end
      it 'should identify manifests missing tests' do
        FileUtils.touch(File.join(@modpath, 'fooper', 'manifests', 'dev', 'b.pp'))
        @tester.options={:modulepath=>@modpath}
        @tester.check_tests(@modpath).should == ['fooper-dev-b.pp']
      end
      it 'should work with multiple modulepaths' do
        @tmpdir = tmpdir('foo')
        @modulepaths = [File.join(@tmpdir, 'path1'), File.join(@tmpdir, 'path2')]
        @modules = ['foo','bar']
        @modulepaths.each_index do |i|
          FileUtils.mkdir_p(File.join(@modulepaths[i], @modules[i], "manifests"))
          FileUtils.touch(File.join(@modulepaths[i], @modules[i], "manifests", 'blah.pp'))
        end
        get_code(@modulepaths.join(':'), :get_tests=>true)[:untested].should =~ ['bar-blah.pp', 'foo-blah.pp']
      end
    end
  end
  describe 'when compiling catalogs' do
    before :each do
      # I can set up tons of stuff here, 
      @modulepath1 = tmpdir('one')
      @modulepath2 = tmpdir('two')
    end
    it 'should be able to compile catalog'
    it 'should do something if catalogs fail to compile'
    describe 'when running noop tests' do
      it 'should be able to apply catalog' do
#        @tester.options.expects(:[]).with(:outputdir).returns('/var/lib/puppet/tests')
#        Puppet::Util::Log.newdestination(:console)
#        Puppet[:noop] = true
#        @tester.noop_tests(['gcc-gcc.pp'])
      end
    end 
  end
  describe 'when getting nodes' do
    it 'should be able to get single node' do
#      Puppet[:yamldir]='/var/lib/puppet/yaml'
#      Puppet[:clientyamldir]='/var/lib/puppet/yaml'
#     puts  @tester.get_nodes('*').inspect
    end
    it 'should be able to get all nodes' do

    end
    it 'should be able to get some nodes' do

    end
  end
end

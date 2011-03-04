require File.join(File.dirname(__FILE__), '../../find_spec_utils.rb')
require 'puppet'
require 'puppet/tools/node'

include Puppet::Tools::Node

describe 'Puppet::Tools::Node' do
  before :each do
    @yamldir=tmpdir('nodetests')
    FileUtils.mkdir(File.join(@yamldir, 'node'))
    Puppet[:yamldir] = @yamldir
    Puppet[:clientyamldir] = @yamldir
    puts 
    Puppet::Node.terminus_class=:yaml
    @nodeobj = Puppet::Node.new('node1').save
    @nodeobj = Puppet::Node.new('node2').save
    @nodeobj = Puppet::Node.new('node3').save
    @nodeobj = Puppet::Node.new('bar').save
    @nodeobj = Puppet::Node.new('bar2').save
  end

  it 'should be able to load single node' do
    get_nodes('node1')[0].name.should == 'node1'
  end
  it 'should be able to load multiple nodes' do
    nodes = ['node1', 'node2', 'node3']
    get_nodes('node*').each do |node|
      nodes.delete(node.name).should == node.name 
    end
  end
  it 'should be able to load all nodes' do
    nodes = ['node1', 'node2', 'node3', 'bar', 'bar2']
    get_nodes('*').each do |node|
      nodes.delete(node.name).should == node.name 
    end
  end
  it 'should be able to set different termini'
end

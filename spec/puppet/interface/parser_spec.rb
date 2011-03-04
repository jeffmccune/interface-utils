require 'puppet'
require 'puppet/interface/parser'

describe 'Puppet::Interface::Parser' do

  before :each do 
    @node_code = ""
    @default_node = 'node default{}'
    @multiline_node = 
'
  node a,b,
    c,
    d {
    
  }
'
    @node_with_code = 'node foo {$bar=blah notify{$bar:}}'
    @regex_node = 'node /a\w?[1-2]/ {}'
    @parser = Puppet::Interface.interface(:parser)
    Puppet[:code]=@node_code
  end
  describe 'when parsing puppet code' do
    it 'should parse single node' do
      Puppet[:code]=@default_node
      @parser.get_node_names().should == ['default']
      @parser.get_nodes.collect do |elem| 
        elem.instance_eval{@name}
      end.should =~ ['default']
    end
    it 'should be able to parse a nodes' do
      Puppet[:code]="#{@multiline_node}\n#{@node_with_code}\n#{@default_node}"
      results = ['a', 'b', 'c', 'd', 'foo', 'default']
      @parser.get_node_names().should =~ results
      @parser.get_nodes.collect do |elem| 
        elem.instance_eval{@name}
      end.should =~ results
    end
    it 'should be able to parse regex' do
      Puppet[:code]=@regex_node
      @parser.get_nodes.collect do |elem| 
        elem.instance_eval{@name.inspect}
      end.should =~ ["/a\\w?[1-2]/"]
    end
    #it 'should be able to parse node ast' do
    #  @parser.code=@node_with_code
    #  @parser.get_node_ast
    #end
  end
end

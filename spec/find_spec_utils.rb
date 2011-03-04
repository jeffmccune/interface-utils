# find all of the puppet spec stuff (more than a little ghetto
def find_puppet_spec()
  puppetdir = $LOAD_PATH.detect do |file|
    File.directory?(File.join(file, 'puppet')) &&
      File.directory?(File.join(file, '../spec/lib'))
  end
  raise Exception, "could not find puppet spec lib" unless puppetdir
  $LOAD_PATH.unshift(File.join(puppetdir, '../spec/lib'))
  require File.join(puppetdir, '../spec/spec_helper')
end
find_puppet_spec
require 'puppet_spec/files'
include PuppetSpec
include PuppetSpec::Files

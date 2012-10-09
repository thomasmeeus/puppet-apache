require 'puppet'
require 'rspec-puppet'
require 'tmpdir'
require 'spec_params'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.before :each do
    # Create a temporary puppet confdir area and temporary site.pp so
    # when rspec-puppet runs we don't get a puppet error.
    @puppetdir = Dir.mktmpdir
    manifestdir = File.join(@puppetdir, "manifests")
    Dir.mkdir(manifestdir)
    FileUtils.touch(File.join(manifestdir, "site.pp"))
    Puppet[:confdir] = @puppetdir
  end

  c.after :each do
    FileUtils.remove_entry_secure(@puppetdir)
  end

#  c.module_path = File.join(File.dirname(__FILE__), '../../')
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end

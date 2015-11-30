require 'rake'
require 'puppetlabs_spec_helper/rake_tasks'
require 'beaker-rspec'

Rake::Task[:spec_prep].invoke

hosts.each do |host|
  # Install Puppet
  on host, install_puppet
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split('/').last
	dependencies_path = module_root + '/spec/fixtures/modules'

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => module_root, :module_name => module_name)

		# Install dependencies		
		Dir.foreach(dependencies_path) do |dependency|
			next if dependency == '.' or dependency == '..'
      dependency_source = dependencies_path+'/'+dependency
			puppet_module_install(:source => dependency_source, :module_name => dependency)
		end

  end
end
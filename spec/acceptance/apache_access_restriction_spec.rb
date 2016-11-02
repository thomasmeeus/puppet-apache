require 'spec_helper_acceptance'

describe 'cegeka_apache::vhost_access_restriction' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include cegeka_apache
        cegeka_apache::vhost { 'www.example.com':
          ensure => present,
        }
        cegeka_apache::vhost_access_restriction { 'www.example.com':
          vhost      => 'www.example.com',
          folder     => '/var/www/vhosts/www.example.com/htdocs',
          allow_from => '127.0.0.1',
          require    => Package['httpd'],
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/var/www/vhosts/www.example.com/conf/00-vhost_access_restriction-www.example.com.conf' do
      it { is_expected.to be_file }
      its(:content) { should match /Allow from/ }
    end
  end
end

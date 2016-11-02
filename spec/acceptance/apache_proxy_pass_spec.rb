require 'spec_helper_acceptance'

describe 'cegeka_apache::proxy_pass' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include cegeka_apache
        cegeka_apache::vhost { 'www.example.com':
          ensure => present,
        }
        cegeka_apache::proxypass { "proxy legacy dir to legacy server":
          ensure       => present,
          location     => "/legacy/",
          url          => "http://legacyserver.example.com",
          params       => ["retry=5", "ttl=120"],
          vhost        => "www.example.com",
          proxy_config => ['ProxyPreserveHost On'],
          require      => Package['httpd'],
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/var/www/vhosts/www.example.com/conf/proxypass-proxy_legacy_dir_to_legacy_server.conf' do
      it { is_expected.to be_file }
      its(:content) { should match /ProxyPass/ }
    end
  end
end

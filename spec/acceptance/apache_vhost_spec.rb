require 'spec_helper_acceptance'

case fact('osfamily')
when 'RedHat'
  vhostd = '/etc/httpd/sites-enabled'
when 'Debian'
  vhostd = '/etc/apache2/sites-enabled'
end

describe 'cegeka_apache::vhost' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include cegeka_apache
        cegeka_apache::vhost { 'www.example.com':
          ensure    => present,
          require   => Package['httpd'],
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file "#{vhostd}/www.example.com" do
      it { is_expected.to be_file }
      its(:content) { should match /ServerName www.example.com/ }
    end
  end
end

require 'spec_helper_acceptance'

describe 'apache::vhost' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include apache
        apache::vhost { 'www.example.com':
          ensure    => present,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/httpd/sites-enabled/www.example.com' do
      it { is_expected.to be_file }
      its(:content) { should match /ServerName www.example.com/ }
    end
  end
end

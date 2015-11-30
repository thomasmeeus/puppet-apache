require 'spec_helper_acceptance'

describe 'apache::redirectmatch' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include apache
        apache::vhost { 'www.example.com':
          ensure    => present,
        }
        apache::redirectmatch { "example":
          regex => "^/(foo|bar)",
          url   => "http://foobar.example.com/",
          vhost => "www.example.com",
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/var/www/vhosts/www.example.com/conf/redirect-example.conf' do
      it { is_expected.to be_file }
      its(:content) { should match /RedirectMatch/ }
    end
  end
end

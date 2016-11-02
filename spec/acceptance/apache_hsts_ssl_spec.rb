require 'spec_helper_acceptance'

describe 'cegeka_apache::vhost::ssl' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include cegeka_apache
        include cegeka_apache::ssl

        cegeka_apache::vhost::ssl { 'test-hsts.example.com':
          ensure      => present,
          enablehsts  => true,
        }
      EOS

      # Dont catch failures, just check the config. Another test tests the ssl definition
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/httpd/sites-available/test-hsts.example.com' do
      it { is_expected.to be_file }
      it { should contain 'Header always set Strict-Transport-Security' }
    end

  end
end

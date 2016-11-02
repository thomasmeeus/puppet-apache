require 'spec_helper_acceptance'

describe 'cegeka_apache::vhost::ssl' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include cegeka_apache::ssl
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(443) do
      it { is_expected.to be_listening }
    end
    
    describe file '/usr/local/sbin/generate-ssl-cert.sh' do
      it { is_expected.to be_file }
      its(:content) { should match /openssl/ }
    end

  end
end

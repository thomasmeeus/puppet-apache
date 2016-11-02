require 'spec_helper_acceptance'

case fact('osfamily')
when 'RedHat'
  confd = '/etc/httpd/conf.d'
when 'Debian'
  confd = '/etc/apache2/conf.d'
end

describe 'cegeka_apache::deflate' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include cegeka_apache
        include cegeka_apache::deflate
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file "#{confd}/deflate.conf" do
      it { is_expected.to be_file }
      its(:content) { should match /mod_deflate.c/ }
    end
  end
end

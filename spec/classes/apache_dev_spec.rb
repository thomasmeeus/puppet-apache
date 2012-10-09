require 'spec_helper'

describe 'apache::dev' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should contain_package(VARS[os]['apache_devel']).with_ensure('present') }

    end
  end
end

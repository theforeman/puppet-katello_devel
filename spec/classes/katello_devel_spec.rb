require 'spec_helper'

describe 'katello_devel' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts.merge(:concat_basedir => '/tmp', :mongodb_version => '2.4.14')
      end

      let(:params) do
        {
          :user => 'vagrant',
          :github_username => 'foo'
        }
      end

      let(:pre_condition) do
        ['include foreman','include certs']
      end

      it { should contain_class('katello_devel::install') }
      it { should contain_class('katello_devel::config') }
      it { should contain_class('katello_devel::database') }
    end
  end
end

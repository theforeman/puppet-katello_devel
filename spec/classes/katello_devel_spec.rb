require 'spec_helper'

describe 'katello_devel' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) do
        {
          :user => 'vagrant',
          :github_username => 'foo',
          :deployment_dir => '/home/vagrant',
        }
      end

      let(:pre_condition) do
        ['include foreman', 'include foreman_proxy', 'include certs']
      end

      it { should contain_class('katello_devel::install') }
      it { should contain_class('katello_devel::config') }
      it { should contain_class('katello_devel::database') }

      it { should contain_file('/usr/local/bin/ktest').with_content(%r{^FOREMAN_PATH=/home/vagrant/foreman$}) }
    end
  end
end

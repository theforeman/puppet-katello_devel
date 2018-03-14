require 'spec_helper'

describe 'katello_devel' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with minimal params' do
        let(:params) do
          {
            :user => 'vagrant',
          }
        end

        let(:pre_condition) do
          ['include foreman', 'include foreman_proxy', 'include certs']
        end

        it { is_expected.to contain_class('katello_devel::install') }
        it { is_expected.to contain_class('katello_devel::config') }
        it { is_expected.to contain_class('katello_devel::database') }
        it { is_expected.to contain_file('/usr/local/bin/ktest').with_content(%r{^FOREMAN_PATH=/home/vagrant/foreman$}) }
      end

      describe 'with github_username' do
        let(:params) do
          {
            :user => 'vagrant',
            :github_username => 'foo',
          }
        end

        let(:pre_condition) do
          ['include foreman', 'include foreman_proxy', 'include certs']
        end

        it { is_expected.to contain_class('katello_devel::install') }
        it { is_expected.to contain_class('katello_devel::config') }
        it { is_expected.to contain_class('katello_devel::database') }
        it { is_expected.to contain_file('/usr/local/bin/ktest').with_content(%r{^FOREMAN_PATH=/home/vagrant/foreman$}) }
      end
    end
  end
end

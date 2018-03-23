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

        it { is_expected.to contain_class('katello_devel::install') }
        it { is_expected.to contain_class('katello_devel::config') }
        it { is_expected.to contain_class('katello_devel::database') }
        it { is_expected.not_to contain_katello_devel__bundle('exec rails s -d') }
        it { is_expected.to contain_file('/usr/local/bin/ktest').with_content(%r{^FOREMAN_PATH=/home/vagrant/foreman$}) }
        it { is_expected.to contain_file('/etc/profile.d/foreman-rake-env.sh').with_content(%r{^SEED_ADMIN_PASSWORD="changeme"$}) }
      end

      describe 'with github_username' do
        let(:params) do
          {
            :user => 'vagrant',
            :github_username => 'foo',
          }
        end

        it { is_expected.to contain_class('katello_devel::install') }
        it { is_expected.to contain_class('katello_devel::config') }
        it { is_expected.to contain_class('katello_devel::database') }
        it { is_expected.not_to contain_katello_devel__bundle('exec rails s -d') }
        it { is_expected.to contain_file('/usr/local/bin/ktest').with_content(%r{^FOREMAN_PATH=/home/vagrant/foreman$}) }
        it { is_expected.to contain_file('/etc/profile.d/foreman-rake-env.sh').with_content(%r{^SEED_ADMIN_PASSWORD="changeme"$}) }
      end

      describe 'with proxy registration' do
        let(:params) do
          {
            :user => 'vagrant',
          }
        end

        let :pre_condition do
          'include foreman_proxy'
        end

        it { is_expected.to contain_class('Foreman_proxy::Register') }
        it { is_expected.to contain_katello_devel__bundle('exec rails s -d') }
      end
    end
  end
end

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

        it { verify_exact_contents(catalogue, '/home/vagrant/foreman/.env', [
          'BIND=0.0.0.0',
          'PORT=3000',
          "RAILS_STARTUP='puma -w 2 -p $PORT --preload'",
          "WEBPACK_OPTS='--https --key /etc/pki/katello/private/katello-apache.key --cert /etc/pki/katello/certs/katello-apache.crt --cacert /etc/pki/katello/certs/katello-default-ca.crt --host 0.0.0.0 --public #{facts[:fqdn]}'",
          "REDUX_LOGGER=false",
        ]) }
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
      end

      describe 'with blank github_username' do
        let(:params) do
          {
            :user => 'vagrant',
            :github_username => '',
          }
        end

        it { is_expected.to contain_class('katello_devel::install') }
        it { is_expected.to contain_class('katello_devel::config') }
        it { is_expected.to contain_class('katello_devel::database') }
        it { is_expected.not_to contain_katello_devel__bundle('exec rails s -d') }
        it { is_expected.to contain_file('/usr/local/bin/ktest').with_content(%r{^FOREMAN_PATH=/home/vagrant/foreman$}) }
      end

      describe 'with proxy registration' do
        let(:params) do
          {
            :user => 'vagrant',
          }
        end

        let(:pre_condition) { 'include "foreman_proxy"' }

        it { is_expected.to contain_class('Foreman_proxy::Register') }
        it { is_expected.to contain_katello_devel__bundle('exec rails s -d') }
      end
    end
  end
end

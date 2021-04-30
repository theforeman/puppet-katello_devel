require 'spec_helper'

describe 'katello_devel' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with minimal params' do
        let(:params) do
          {
            :user => 'vagrant',
            :oauth_key => 'OAUTH_KEY',
            :oauth_secret => 'OAUTH_SECRET',
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

        it do
          verify_exact_contents(catalogue, '/home/vagrant/foreman/config/settings.plugins.d/katello.yaml', [
            ':katello:',
            '  :rest_client_timeout: 3600',
            '  :katello_applicability: true',
            '  :content_types:',
            '    :file: true',
            '    :yum: true',
            '    :deb: true',
            '    :puppet: false',
            '    :docker: true',
            '    :ostree: false',
            '    :ansible_collection: true',
            '  :candlepin:',
            '    :url: https://localhost:23443/candlepin',
            '    :oauth_key: OAUTH_KEY',
            '    :oauth_secret: OAUTH_SECRET',
            '    :ca_cert_file: /etc/pki/katello/certs/katello-default-ca.crt',
            '  :candlepin_events:',
            '    :ssl_cert_file: /etc/pki/katello/certs/java-client.crt',
            '    :ssl_key_file: /etc/pki/katello/private/java-client.key',
            '    :ssl_ca_file: /etc/pki/katello/certs/katello-default-ca.crt',
            '  :agent:',
            '    :broker_url: amqps://localhost:5671',
            '    :event_queue_name: katello.agent',
            '  :katello_applicability: true',
          ])
        end
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

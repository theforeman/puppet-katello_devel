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

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('nodejs').with_provider('dnfmodule').with_ensure('12') }
        it { is_expected.to contain_package('npm') }

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
          verify_exact_contents(catalogue, '/home/vagrant/foreman/config/settings.yaml', [
            ':unattended: true',
            ':login: true',
            ':require_ssl: false',
            ':locations_enabled: true',
            ':organizations_enabled: true',
            ':oauth_active: true',
            ':oauth_map_users: true',
            ':oauth_consumer_key: OAUTH_KEY',
            ':oauth_consumer_secret: OAUTH_SECRET',
            ':ssl_ca_file: /home/vagrant/foreman-certs/proxy_ca.pem',
            ':ssl_certificate: /home/vagrant/foreman-certs/client_cert.pem',
            ':ssl_priv_key: /home/vagrant/foreman-certs/client_key.pem',
            ':webpack_dev_server: true',
            ':webpack_dev_server_https: true',
            ':assets_debug: false',
            ':loggers:',
            '  :audit:',
            '    :enabled: true',
            '    :level: error',
            '  :taxonomy:',
            '    :enabled: true',
            '    :level: error',
            '  :dynflow:',
            '    :enabled: true',
            '    :level: info',
          ])
        end

        it do
          verify_exact_contents(catalogue, '/home/vagrant/foreman/config/settings.plugins.d/katello.yaml', [
            ':katello:',
            '  :rest_client_timeout: 3600',
            '  :katello_applicability: true',
            '  :candlepin:',
            '    :url: https://localhost:23443/candlepin',
            '    :oauth_key: OAUTH_KEY',
            '    :oauth_secret: OAUTH_SECRET',
            '    :ca_cert_file: /etc/pki/katello/certs/katello-default-ca.crt',
            '  :candlepin_events:',
            '    :ssl_cert_file: /home/vagrant/foreman-certs/client_cert.pem',
            '    :ssl_key_file: /home/vagrant/foreman-certs/client_key.pem',
            '    :ssl_ca_file: /etc/pki/katello/certs/katello-default-ca.crt',
            '  :agent:',
            '    :broker_url: amqps://localhost:5671',
            '    :event_queue_name: katello.agent',
            '    :enabled: false',
            '  :katello_applicability: true',
          ])
        end
      end

      describe 'with modulestream_nodejs' do
        let(:params) do
          {
            :user => 'vagrant',
            :oauth_key => 'OAUTH_KEY',
            :oauth_secret => 'OAUTH_SECRET',
            :modulestream_nodejs => '14',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('nodejs').with_provider('dnfmodule').with_ensure('14') }
        it { is_expected.to contain_package('npm') }
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

      describe 'extra plugins' do
        context 'with foo plugin' do
          let(:params) do
            {
              :user => 'vagrant',
              :extra_plugins => ['theforeman/foo'],
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_katello_devel__plugin('theforeman/foo') }
          it { is_expected.to contain_katello_devel__git_repo('foo') }
        end

        context 'with an additional plugin with unmanaged source repository' do
          let(:params) do
            {
              :user => 'vagrant',
              :extra_plugins => ['theforeman/foo', { 'name' => 'customorg/bar', 'manage_repo' => false }],
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_katello_devel__plugin('theforeman/foo') }
          it { is_expected.to contain_katello_devel__git_repo('foo') }
          it { is_expected.to contain_katello_devel__plugin('customorg/bar') }
          it { is_expected.not_to contain_katello_devel__git_repo('bar') }
        end
      end
    end
  end
end

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
        it { is_expected.to contain_package('nodejs').with_provider('dnfmodule').with_ensure('18') }
        it { is_expected.to contain_package('npm') }

        it { is_expected.to contain_class('katello_devel::install') }
        it { is_expected.to contain_class('katello_devel::config') }
        it { is_expected.to contain_katello_devel__plugin('katello/katello') }
        it { is_expected.to contain_katello_devel__git_repo('foreman') }
        it { is_expected.to contain_katello_devel__git_repo('katello') }
        it { is_expected.to contain_katello_devel__git_repo('foreman_remote_execution') }
        it { is_expected.to contain_class('katello_devel::database') }
        it { is_expected.not_to contain_katello_devel__bundle('exec rails s -d') }
        it { is_expected.to contain_file('/usr/local/bin/ktest').with_content(%r{^FOREMAN_PATH=/home/vagrant/foreman$}) }

        it { verify_exact_contents(catalogue, '/home/vagrant/foreman/.env', [
          'BIND=0.0.0.0',
          'PORT=3000',
          "RAILS_STARTUP='puma -w 2 -p $PORT --preload'",
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
            ':ssl_client_dn_env: HTTP_SSL_CLIENT_S_DN',
            ':ssl_client_verify_env: HTTP_SSL_CLIENT_VERIFY',
            ':ssl_client_cert_env: HTTP_SSL_CLIENT_CERT',
            ':assets_debug: false',
            ':rails_cache_store:',
            '  :type: redis',
            '  :urls:',
            '    - redis://localhost:6379/4',
            '  :options:',
            '    :compress: true',
            '    :namespace: foreman',
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
            '  :katello_applicability: true',
          ])
        end

        it do
          verify_exact_contents(catalogue, '/home/vagrant/foreman/bundler.d/katello.local.rb', [
            "gemspec :path => '../katello', :development_group => 'katello_dev', :name => 'katello'",
            "eval_gemfile('/home/vagrant/katello/gemfile.d/test.rb')"
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

      describe 'unmanaged foreman repo' do
        let(:params) do
          {
            :user => 'vagrant',
            :foreman_manage_repo => false,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_katello_devel__git_repo('foreman') }
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

        context 'with an additional plugin with specified repository branch' do
          let(:params) do
            {
              :user => 'vagrant',
              :extra_plugins => ['theforeman/foo', { 'name' => 'customorg/bar', 'scm_revision' => '1.2.3-stable' }],
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_katello_devel__plugin('theforeman/foo') }
          it { is_expected.to contain_katello_devel__git_repo('foo') }
          it { is_expected.to contain_katello_devel__plugin('customorg/bar') }
          it { is_expected.to contain_katello_devel__git_repo('bar').with_source('customorg/bar') }
          it { is_expected.to contain_katello_devel__git_repo('bar').with_revision('1.2.3-stable') }
        end

        context 'with unmanaged katello repo' do
          let(:params) do
            {
              :user => 'vagrant',
              :katello_manage_repo => false,
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_katello_devel__plugin('katello/katello') }
          it { is_expected.not_to contain_katello_devel__git_repo('katello') }
        end

        context 'with unmanaged foreman_remote_execution repo' do
          let(:params) do
            {
              :user => 'vagrant',
              :rex_manage_repo => false,
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_katello_devel__plugin('theforeman/foreman_remote_execution') }
          it { is_expected.not_to contain_katello_devel__git_repo('foreman_remote_execution') }
        end
      end

      context 'with custom foreman_remote_execution repo revision' do
        let(:params) do
          {
            :user => 'vagrant',
            :rex_scm_revision => '1.2.z',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_katello_devel__plugin('theforeman/foreman_remote_execution') }
        it { is_expected.to contain_katello_devel__git_repo('foreman_remote_execution').with_revision('1.2.z') }
      end

      context 'with enable_iop true' do
        let(:params) do
          {
            :user => 'vagrant',
            :enable_iop => true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('katello_devel::iop') }
        it { is_expected.to contain_class('katello_devel::apache') }
      end

      context 'with iop_proxy_assets_apps true' do
        let(:params) do
          {
            :user => 'vagrant',
            :enable_iop => true,
            :iop_proxy_assets_apps => true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('katello_devel::iop') }
        it { is_expected.to contain_class('katello_devel::apache') }
      end

      context 'with iop_proxy_assets_apps true but enable_iop false' do
        let(:params) do
          {
            :user => 'vagrant',
            :enable_iop => false,
            :iop_proxy_assets_apps => true,
          }
        end

        it { is_expected.to compile.and_raise_error(/iop_proxy_assets_apps requires enable_iop to be true/) }
      end
    end
  end
end

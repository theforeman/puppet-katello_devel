# @summary Install and configure Katello for development
#
# @param user
#   The Katello system user name
#
# @param deployment_dir
#   Location to deploy Katello to in development
#
# @param oauth_key
#   The oauth key for talking to the candlepin API
#
# @param oauth_secret
#   The oauth secret for talking to the candlepin API
#
# @param post_sync_token
#   The shared secret for pulp notifying katello about completed syncs
#
#
# @param modulestream_nodejs
#   The nodejs modularity stream to use on EL8 and up
#
# @param manage_bundler
#   If set to true, will execute the bundler commands needed to run the foreman
#   server.
#
# @param initial_organization
#   Initial organization to be created
#
# @param initial_location
#   Initial location to be created
#
# @param admin_password
#   Admin user password for Web application
#
# @param github_username
#   Github username to add remotes for
#
# @param use_ssh_fork
#   If true, will use SSH to configure Github fork, otherwise HTTPS.
#
# @param fork_remote_name
#   Name of the remote that represents your fork
#
# @param upstream_remote_name
#   Name of the remote that represents the upstream repository
#
# @param extra_plugins
#   Array of Github namespace/repo plugins to setup and configure from git
#
# @param rails_command
#   Customize the command used to start rails
#
# @param npm_timeout
#   Timeout for npm install step
#
# @param foreman_scm_revision
#   Branch or revision to use for Foreman's git checkout
#
# @param katello_scm_revision
#   Branch or revision to use for katello's git checkout
#
# @param rex_scm_revision
#   Branch or revision to use for foreman_remote_execution's git checkout
#
# @param foreman_manage_repo
#   Manage the Foreman git repository
#
# @param katello_manage_repo
#   Manage the Katello git repository
#
# @param rex_manage_repo
#   Manage the Foreman Remote Execution git repository
#
# @param rails_cache_store
#   Manage the type of cache used for Rails, default is Redis.
#
# @param enable_iop
#   Enable iop integration
#
# @param iop_proxy_assets_apps
#   Configure Apache to proxy /assets/apps to a backend running on localhost:8002
#
class katello_devel (
  String $user = undef,
  Stdlib::Absolutepath $deployment_dir = '/home/vagrant',
  String $oauth_key = $katello_devel::params::oauth_key,
  String $oauth_secret = $katello_devel::params::oauth_secret,
  String $post_sync_token = 'test',
  String $modulestream_nodejs = '18',
  Boolean $manage_bundler = true,
  String $initial_organization = 'Default Organization',
  String $initial_location = 'Default Location',
  String $admin_password = 'changeme',
  Optional[String] $github_username = undef,
  Boolean $use_ssh_fork = false,
  Optional[String] $fork_remote_name = undef,
  String $upstream_remote_name = 'upstream',
  Array[Variant[String,Hash]] $extra_plugins = $katello_devel::params::extra_plugins,
  String $rails_command = 'puma -w 2 -p $PORT --preload',
  Integer[0] $npm_timeout = 2700,
  String $foreman_scm_revision = 'develop',
  String $katello_scm_revision = 'master',
  String $rex_scm_revision = 'master',
  Boolean $foreman_manage_repo = true,
  Boolean $katello_manage_repo = true,
  Boolean $rex_manage_repo = true,
  Hash[String, Any] $rails_cache_store = { 'type' => 'redis' },
  Boolean $enable_iop = false,
  Boolean $iop_proxy_assets_apps = false,
) inherits katello_devel::params {
  if $iop_proxy_assets_apps and !$enable_iop {
    fail('iop_proxy_assets_apps requires enable_iop to be true')
  }

  $group = $user

  $changeme = '$6$lb06/IMy$nZhR3LkR2tUunTQm68INFWMyb/8VA2vfYq0/fRzLoKSfuri.vvtjeLJf9V.wuHzw92.aw8NgUlJchMy/qK25x.'

  user { $user:
    ensure     => present,
    managehome => true,
    password   => $changeme,
  } ~>
  group { $group:
    ensure => present,
  }

  class { 'katello::params':
    candlepin_oauth_key            => $oauth_key,
    candlepin_oauth_secret         => $oauth_secret,
    candlepin_client_keypair_group => $group,
  }

  $fork_remote_name_real = pick_default($fork_remote_name, $github_username)

  $foreman_dir = "${deployment_dir}/foreman"
  $foreman_cert_dir = "${deployment_dir}/foreman-certs"

  include certs

  $candlepin_url = $katello::params::candlepin_url
  $candlepin_ca_cert = $certs::katello_default_ca_cert

  $ssl_ca_file = "${foreman_cert_dir}/proxy_ca.pem"
  $ssl_certificate = "${foreman_cert_dir}/client_cert.pem"
  $ssl_priv_key = "${foreman_cert_dir}/client_key.pem"

  file { $foreman_cert_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0775',
  }

  class { 'certs::foreman':
    client_cert => $ssl_certificate,
    client_key  => $ssl_priv_key,
    ssl_ca_cert => $ssl_ca_file,
    owner       => $user,
    group       => $group,
    before      => Class['katello_devel::config'],
  }

  Class['certs'] ~>
  class { 'certs::apache': } ~>
  class { 'katello_devel::apache': } ~>
  class { 'katello_devel::install': } ~>
  class { 'katello_devel::config': } ~>
  class { 'katello_devel::database': }

  if $manage_bundler {
    class { 'katello_devel::setup':
      require   => Class['katello::candlepin'],
      subscribe => Class['katello_devel::database'],
    }
  }

  $artemis_client_dn = katello::build_dn([['CN', $certs::foreman::hostname], ['OU', $certs::foreman::org_unit], ['O', $certs::foreman::org], ['ST', $certs::foreman::state], ['C', $certs::foreman::country]])

  class { 'katello::candlepin':
    artemis_client_dn => $artemis_client_dn,
  }

  file { '/usr/local/bin/ktest':
    ensure  => file,
    content => template('katello_devel/ktest.sh.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0755',
  }

  if $enable_iop {
    include katello_devel::iop
  }
}

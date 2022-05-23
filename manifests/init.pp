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
# @param webpack_dev_server
#   Whether to use the webpack dev server. Otherwise uses statically compiled
#   bundles.
#
# @param use_rvm
#   If set to true, will install and configure RVM
#
# @param rvm_ruby
#   The default Ruby version to use with RVM
#
# @param rvm_branch
#   The branch to install RVM from; 'stable' or 'head'
#
# @param scl_ruby
#   The default Ruby version to use with SCL
#
# @param qpid_wcache_page_size
#   The size (in KB) of the pages in the write page cache
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
class katello_devel (
  String $user = undef,
  Stdlib::Absolutepath $deployment_dir = '/home/vagrant',
  String $oauth_key = $katello_devel::params::oauth_key,
  String $oauth_secret = $katello_devel::params::oauth_secret,
  String $post_sync_token = 'test',
  Boolean $webpack_dev_server = true,
  Boolean $use_rvm = false,
  String $rvm_ruby = '2.7',
  String $rvm_branch = 'stable',
  Optional[String] $scl_ruby = $katello_devel::params::scl_ruby,
  Boolean $manage_bundler = true,
  String $initial_organization = 'Default Organization',
  String $initial_location = 'Default Location',
  String $admin_password = 'changeme',
  Optional[String] $github_username = undef,
  Boolean $use_ssh_fork = false,
  Optional[String] $fork_remote_name = undef,
  String $upstream_remote_name = 'upstream',
  Integer[0, 1000] $qpid_wcache_page_size = 4,
  Array[String] $extra_plugins = $katello_devel::params::extra_plugins,
  String $rails_command = 'puma -w 2 -p $PORT --preload',
  Integer[0] $npm_timeout = 2700,
  String $foreman_scm_revision = 'develop',
  String $katello_scm_revision = 'master',
) inherits katello_devel::params {

  $qpid_hostname = 'localhost'

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
    qpid_hostname                  => $qpid_hostname,
  }

  $fork_remote_name_real = pick_default($fork_remote_name, $github_username)

  $foreman_dir = "${deployment_dir}/foreman"
  $foreman_cert_dir = "${deployment_dir}/foreman-certs"

  include certs

  $candlepin_url = $katello::params::candlepin_url
  $candlepin_ca_cert = $certs::ca_cert

  $ssl_ca_file = "${foreman_cert_dir}/proxy_ca.pem"
  $ssl_certificate = "${foreman_cert_dir}/client_cert.pem"
  $ssl_priv_key = "${foreman_cert_dir}/client_key.pem"

  include certs::pulp_client

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

  include katello::candlepin

  class { 'katello::qpid':
    wcache_page_size => $qpid_wcache_page_size,
  }

  file { '/usr/local/bin/ktest':
    ensure  => file,
    content => template('katello_devel/ktest.sh.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0755',
  }
}

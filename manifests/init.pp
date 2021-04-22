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
# @param enable_yum
#   Enable rpm content plugin, including syncing of yum content
#
# @param enable_file
#   Enable generic file content management
#
# @param enable_docker
#   Enable docker content plugin
#
# @param enable_deb
#   Enable debian content plugin
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
#   Name of the remove that represents the upstream repository
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
  String $user = $katello_devel::params::user,
  Stdlib::Absolutepath $deployment_dir = $katello_devel::params::deployment_dir,
  String $oauth_key = $katello_devel::params::oauth_key,
  String $oauth_secret = $katello_devel::params::oauth_secret,
  String $post_sync_token = $katello_devel::params::post_sync_token,
  Boolean $webpack_dev_server = $katello_devel::params::webpack_dev_server,
  Boolean $use_rvm = $katello_devel::params::use_rvm,
  String $rvm_ruby = $katello_devel::params::rvm_ruby,
  String $rvm_branch = $katello_devel::params::rvm_branch,
  Optional[String] $scl_ruby = $katello_devel::params::scl_ruby,
  Boolean $manage_bundler = $katello_devel::params::manage_bundler,
  String $initial_organization = $katello_devel::params::initial_organization,
  String $initial_location = $katello_devel::params::initial_location,
  String $admin_password = $katello_devel::params::admin_password,
  Boolean $enable_yum = $katello_devel::params::enable_yum,
  Boolean $enable_file = $katello_devel::params::enable_file,
  Boolean $enable_docker = $katello_devel::params::enable_docker,
  Boolean $enable_deb = $katello_devel::params::enable_deb,
  Optional[String] $github_username = $katello_devel::params::github_username,
  Boolean $use_ssh_fork = $katello_devel::params::use_ssh_fork,
  Optional[String] $fork_remote_name = $katello_devel::params::fork_remote_name,
  String $upstream_remote_name = $katello_devel::params::upstream_remote_name,
  Integer[0, 1000] $qpid_wcache_page_size = $katello_devel::params::qpid_wcache_page_size,
  Array[String] $extra_plugins = $katello_devel::params::extra_plugins,
  String $rails_command = $katello_devel::params::rails_command,
  Integer[0] $npm_timeout = $katello_devel::params::npm_timeout,
  String $foreman_scm_revision = $katello_devel::params::foreman_scm_revision,
  String $katello_scm_revision = $katello_devel::params::katello_scm_revision,
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

  class { 'katello::globals':
    enable_yum    => $enable_yum,
    enable_file   => $enable_file,
    enable_docker => $enable_docker,
    enable_deb    => $enable_deb,
  }

  class { 'katello::params':
    candlepin_oauth_key            => $oauth_key,
    candlepin_oauth_secret         => $oauth_secret,
    candlepin_client_keypair_group => $group,
    qpid_hostname                  => $qpid_hostname,
  }

  $fork_remote_name_real = pick_default($fork_remote_name, $github_username)

  $foreman_dir = "${deployment_dir}/foreman"

  include certs

  $candlepin_url = $katello::params::candlepin_url
  $candlepin_ca_cert = $certs::ca_cert

  include certs::pulp_client

  Class['certs'] ~>
  class { 'certs::apache': } ~>
  class { 'katello_devel::apache': } ~>
  class { 'katello_devel::install': } ~>
  class { 'katello_devel::foreman_certs': } ~>
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

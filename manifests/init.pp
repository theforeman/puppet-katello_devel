# == Class: katello_devel
#
# Install and configure Katello for development
#
# === Parameters:
#
# $user::                     The Katello system user name
#
# $deployment_dir::           Location to deploy Katello to in development
#
# $oauth_key::                The oauth key for talking to the candlepin API
#
# $oauth_secret::             The oauth secret for talking to the candlepin API
#
# $post_sync_token::          The shared secret for pulp notifying katello about
#                             completed syncs
#
# $db_type::                  The database type; 'postgres' or 'sqlite'
#
# $use_rvm::                  If set to true, will install and configure RVM
#
# $rvm_ruby::                 The default Ruby version to use with RVM
#
# $rvm_branch::               The branch to install RVM from; 'stable' or 'head'
#
# $qpid_wcache_page_size::    The size (in KB) of the pages in the write page cache
#
# $initial_organization::     Initial organization to be created
#
# $initial_location::         Initial location to be created
#
# $admin_password::           Admin user password for Web application
#
# $enable_ostree::            Boolean to enable ostree plugin. This requires existence of an ostree install.
#
# $candlepin_event_queue::    The queue to use for candlepin
#
# $candlepin_qpid_exchange::  The exchange to use for candlepin
#
# $github_username::          Github username to add remotes for
#
# $use_ssh_fork::             If true, will use SSH to configure Github fork, otherwise HTTPS.
#
# $fork_remote_name::         Name of the remote that represents your fork
#
# $upstream_remote_name::     Name of the remove that represents the upstream repository
#
# $extra_plugins::            Array of Github namespace/repo plugins to setup and configure from git
#
class katello_devel (
  String $user = $katello_devel::params::user,
  Stdlib::Absolutepath $deployment_dir = $katello_devel::params::deployment_dir,
  String $oauth_key = $katello_devel::params::oauth_key,
  String $oauth_secret = $katello_devel::params::oauth_secret,
  String $post_sync_token = $katello_devel::params::post_sync_token,
  Enum['postgres', 'sqlite'] $db_type = $katello_devel::params::db_type,
  Boolean $use_rvm = $katello_devel::params::use_rvm,
  String $rvm_ruby = $katello_devel::params::rvm_ruby,
  String $rvm_branch = $katello_devel::params::rvm_branch,
  String $initial_organization = $katello_devel::params::initial_organization,
  String $initial_location = $katello_devel::params::initial_location,
  String $admin_password = $katello_devel::params::admin_password,
  Boolean $enable_ostree = $katello_devel::params::enable_ostree,
  String $candlepin_event_queue = $katello_devel::params::candlepin_event_queue,
  String $candlepin_qpid_exchange = $katello_devel::params::candlepin_qpid_exchange,
  String $github_username = $katello_devel::params::github_username,
  Boolean $use_ssh_fork = $katello_devel::params::use_ssh_fork,
  Optional[String] $fork_remote_name = $katello_devel::params::fork_remote_name,
  String $upstream_remote_name = $katello_devel::params::upstream_remote_name,
  Integer[0, 1000] $qpid_wcache_page_size = $::katello_devel::params::qpid_wcache_page_size,
  Array[String] $extra_plugins = $katello_devel::params::extra_plugins,
) inherits katello_devel::params {

  $fork_remote_name_real = pick($fork_remote_name, $github_username)

  $foreman_dir = "${deployment_dir}/foreman"

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

  $foreman_url = "https://${::fqdn}/"
  $candlepin_url = "https://${::fqdn}:8443/candlepin"
  $candlepin_ca_cert = $::certs::ca_cert
  $pulp_url      = "https://${::fqdn}/pulp/api/v2/"
  $pulp_ca_cert = $::certs::ca_cert
  $qpid_hostname = 'localhost'
  $qpid_url = "amqp:ssl:${qpid_hostname}:5671"

  include ::certs::pulp_client
  include ::katello::qpid_client

  Class['certs'] ~>
  class { '::certs::apache': } ~>
  class { '::katello_devel::apache': } ~>
  class { '::katello_devel::install':
    require => Class['katello::qpid_client'],
  } ~>
  class { '::katello_devel::config': } ~>
  class { '::katello_devel::database': } ~>
  class { '::katello_devel::foreman_certs': } ~>
  class { '::katello_devel::setup':
    require => Class['katello::candlepin'],
  }

  class { '::katello::candlepin':
    user_groups   => $group,
    oauth_key     => $oauth_key,
    oauth_secret  => $oauth_secret,
    db_host       => 'localhost',
    db_port       => 5432,
    db_name       => 'candlepin',
    db_user       => 'candlepin',
    db_password   => cache_data('foreman_cache_data', 'candlepin_db_password', random_password(32)),
    db_ssl        => false,
    db_ssl_verify => true,
    manage_db     => true,
    qpid_hostname => $qpid_hostname,
    require       => Class['katello_devel::database'],
  }

  # TODO: Use ::katello::pulp
  include ::certs::qpid_client
  class { '::pulp':
    oauth_enabled          => true,
    oauth_key              => $oauth_key,
    oauth_secret           => $oauth_secret,
    messaging_url          => 'ssl://localhost:5671',
    messaging_ca_cert      => $::certs::ca_cert,
    messaging_client_cert  => $::certs::qpid_client::messaging_client_cert,
    messaging_transport    => 'qpid',
    messaging_auth_enabled => false,
    broker_url             => 'qpid://localhost:5671',
    broker_use_ssl         => true,
    consumers_crl          => $::candlepin::crl_file,
    manage_broker          => false,
    manage_httpd           => false,
    manage_squid           => true,
    enable_rpm             => true,
    enable_puppet          => true,
    enable_docker          => true,
    enable_parent_node     => false,
    enable_katello         => true,
    default_password       => 'admin',
    repo_auth              => true,
    enable_ostree          => $enable_ostree,
    subscribe              => Class['certs::qpid_client'],
  }

  class { '::katello::qpid':
    interface               => 'lo',
    hostname                => 'localhost',
    katello_user            => $user,
    candlepin_event_queue   => $candlepin_event_queue,
    candlepin_qpid_exchange => $candlepin_qpid_exchange,
    wcache_page_size        => $qpid_wcache_page_size,
  }

  file { '/usr/local/bin/ktest':
    ensure  => file,
    content => template('katello_devel/ktest.sh.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0755',
  }
}

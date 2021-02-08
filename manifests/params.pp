# @summary Katello development parameters
# @api private
class katello_devel::params {
  $user = undef

  $oauth_key          = extlib::cache_data('foreman_cache_data', 'oauth_consumer_key', extlib::random_password(32))
  $oauth_secret       = extlib::cache_data('foreman_cache_data', 'oauth_consumer_secret', extlib::random_password(32))

  $deployment_dir = '/home/vagrant'

  $rails_port = 3000

  $post_sync_token = 'test'

  $webpack_dev_server = true

  $use_rvm = false
  $rvm_ruby = '2.5'
  $rvm_branch = 'stable'

  if $facts['os']['release']['major'] == '7' {
    $scl_ruby = 'rh-ruby25'
    $scl_nodejs = 'rh-nodejs12'
    $scl_postgresql = 'rh-postgresql12'
  } else {
    $scl_ruby = undef
    $scl_nodejs = undef
    $scl_postgresql = undef
  }

  $manage_bundler = true

  $initial_organization = 'Default Organization'
  $initial_location = 'Default Location'
  $admin_password = 'changeme'
  $enable_yum = true
  $enable_file = true
  $enable_docker = true
  $enable_deb = $facts['os']['release']['major'] == '7'

  $github_username = undef
  $use_ssh_fork = false
  $fork_remote_name = undef
  $upstream_remote_name = 'upstream'

  $foreman_scm_revision = 'develop'
  $katello_scm_revision = 'master'

  $extra_plugins = []

  $qpid_wcache_page_size = 4

  $rails_command='puma -w 2 -p $PORT --preload'

  $npm_timeout = 900
}

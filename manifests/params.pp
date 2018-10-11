# Katello development parameters
class katello_devel::params {
  $user = undef

  $oauth_key          = extlib::cache_data('foreman_cache_data', 'oauth_consumer_key', extlib::random_password(32))
  $oauth_secret       = extlib::cache_data('foreman_cache_data', 'oauth_consumer_secret', extlib::random_password(32))

  $db_type = 'sqlite'

  $deployment_dir = '/home/vagrant'

  $rails_port = 3000

  $post_sync_token = 'test'

  $webpack_dev_server = true

  $use_rvm = false
  $rvm_ruby = '2.5'
  $rvm_branch = 'stable'

  $use_scl_ruby = true
  $scl_ruby = 'rh-ruby25'

  $manage_bundler = true

  $initial_organization = 'Default Organization'
  $initial_location = 'Default Location'
  $admin_password = 'changeme'
  $enable_ostree = true
  $enable_yum = true
  $enable_file = true
  $enable_puppet = true
  $enable_docker = true
  $enable_deb = true

  $github_username = undef
  $use_ssh_fork = false
  $fork_remote_name = undef
  $upstream_remote_name = 'upstream'

  $extra_plugins = []

  $candlepin_event_queue = 'katello_event_queue'
  $candlepin_qpid_exchange = 'event'

  $qpid_wcache_page_size = 4

  $rails_command='puma -w 5 -p $PORT --preload'
}

# Katello development parameters
class katello_devel::params {
  $user = undef

  $oauth_key          = cache_data('foreman_cache_data', 'oauth_consumer_key', random_password(32))
  $oauth_secret       = cache_data('foreman_cache_data', 'oauth_consumer_secret', random_password(32))

  $db_type = 'sqlite'

  $deployment_dir = '/home/vagrant'

  $post_sync_token = 'test'

  $use_rvm = true
  $rvm_ruby = '2.4'
  $rvm_branch = 'stable'

  $initial_organization = 'Default Organization'
  $initial_location = 'Default Location'
  $admin_password = 'changeme'
  $enable_ostree = false

  $github_username = undef
  $use_ssh_fork = false
  $fork_remote_name = undef
  $upstream_remote_name = 'upstream'

  $extra_plugins = []

  $candlepin_event_queue = 'katello_event_queue'
  $candlepin_qpid_exchange = 'event'

  $qpid_wcache_page_size = 4
}

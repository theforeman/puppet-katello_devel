# @summary Katello development parameters
# @api private
class katello_devel::params {
  $oauth_key          = extlib::cache_data('foreman_cache_data', 'oauth_consumer_key', extlib::random_password(32))
  $oauth_secret       = extlib::cache_data('foreman_cache_data', 'oauth_consumer_secret', extlib::random_password(32))

  $rails_port = 3000

  $extra_plugins = []
}

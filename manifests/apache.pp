# @summary Setups Apache for Katello development
# @api private
class katello_devel::apache {
  $proxy_no_proxy_uris = ['/pulp', '/pub', '/icons', '/images', '/server-status']

  if $katello_devel::enable_iop and !$katello_devel::iop_proxy_assets_apps {
    $_proxy_no_proxy_uris = $proxy_no_proxy_uris + ['/assets/apps']
  } else {
    $_proxy_no_proxy_uris = $proxy_no_proxy_uris
  }

  class { 'foreman::config::apache':
    ssl                 => true,
    ssl_cert            => $certs::apache::apache_cert,
    ssl_key             => $certs::apache::apache_key,
    ssl_ca              => $certs::apache::apache_client_ca_cert,
    ssl_chain           => $certs::apache::apache_ca_cert,
    proxy_backend       => "http://localhost:${katello_devel::rails_port}/",
    proxy_assets        => true,
    proxy_no_proxy_uris => $_proxy_no_proxy_uris,
  }

  # required by configuration in katello/katello-apache-ssl.conf
  include apache::mod::setenvif

  foreman::config::apache::fragment { 'katello':
    ssl_content => file('katello/katello-apache-ssl.conf'),
  }

  if $katello_devel::iop_proxy_assets_apps {
    foreman::config::apache::fragment { 'katello-iop-assets':
      ssl_content => 'ProxyPass /assets/apps http://localhost:8002/apps/',
    }
  }

  User<|title == apache|> { groups +> $katello_devel::group }
}

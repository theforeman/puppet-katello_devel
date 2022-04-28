# @summary Setups Apache for Katello development
# @api private
class katello_devel::apache {

  class { 'foreman::config::apache':
    ssl           => true,
    ssl_cert      => $certs::apache::apache_cert,
    ssl_key       => $certs::apache::apache_key,
    ssl_ca        => $certs::apache::ca_cert,
    ssl_chain     => $certs::apache::apache_ca_cert,
    proxy_backend => "http://localhost:${katello_devel::rails_port}/",
  }

  # required by configuration in katello/katello-apache-ssl.conf
  include apache::mod::setenvif

  foreman::config::apache::fragment { 'katello':
    ssl_content => file('katello/katello-apache-ssl.conf'),
  }

  User<|title == apache|>{groups +> $katello_devel::group}
}

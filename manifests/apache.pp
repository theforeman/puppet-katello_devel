# Setups Apache for Katello development
class katello_devel::apache {

  include apache

  $proxy_pass_https = [
    {
      'no_proxy_uris' => ['/pulp', '/streamer', '/pub'],
      'path'          => '/',
      'url'           => "http://localhost:${katello_devel::rails_port}/",
      'params'        => {'retry' => '0'},
    },
    {
      'path'          => '/',
      'url'           => 'http://localhost:6006/',
      'params'        => {'retry' => '0'},
    },
  ]

  apache::vhost { 'katello-ssl':
    servername          => $certs::apache::hostname,
    serveraliases       => $certs::apache::cname,
    docroot             => '/var/www',
    port                => 443,
    priority            => '05',
    options             => ['SymLinksIfOwnerMatch'],
    ssl                 => true,
    ssl_cert            => $certs::apache::apache_cert,
    ssl_key             => $certs::apache::apache_key,
    ssl_ca              => $certs::apache::ca_cert,
    ssl_verify_client   => 'optional',
    ssl_options         => '+StdEnvVars',
    ssl_verify_depth    => '3',
    custom_fragment     => file('katello/katello-apache-ssl.conf'),
    ssl_proxyengine     => true,
    proxy_pass          => $proxy_pass_https,
    proxy_preserve_host => true,
    request_headers     => ["set X_FORWARDED_PROTO 'https'"],
  }

  # used in template below
  $pub_dir_options = '+FollowSymLinks +Indexes'

  concat::fragment { 'katello-ssl-pulp':
    target  => '05-katello-ssl.conf',
    order   => 271,
    content => template('katello/pulp-apache-ssl.conf.erb'),
  }

  $rewrite_to_https = [
    {
      rewrite_cond => [
        '%{REQUEST_URI} !^\/pulp\/.*',
        '%{REQUEST_URI} !^\/pulp$',
        '%{REQUEST_URI} !^\/pub\/.*',
        '%{REQUEST_URI} !^\/pub$',
        '%{REQUEST_URI} !^\/unattended\/.*',
        '%{REQUEST_URI} !^\/unattended$',
        '%{REQUEST_URI} !^\/streamer\/.*',
        '%{REQUEST_URI} !^\/streamer$',
        '%{HTTPS} off',
      ],
      rewrite_rule => ['(.*) https://%{SERVER_NAME}$1 [L,R=301]'],
    },
  ]

  $proxy_pass_http = [
    {
      'path' => '/unattended',
      'url'  => "http://localhost:${katello_devel::rails_port}/unattended",
    },
  ]

  apache::vhost { 'katello':
    servername      => $facts['fqdn'],
    serveraliases   => ['katello'],
    docroot         => '/var/www/html',
    port            => 80,
    priority        => '05',
    options         => ['SymLinksIfOwnerMatch'],
    ssl             => false,
    rewrites        => $rewrite_to_https,
    proxy_pass      => $proxy_pass_http,
    custom_fragment => template('katello/pulp-apache.conf.erb'),
  }

  User<|title == apache|>{groups +> $katello_devel::group}
}

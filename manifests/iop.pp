# @summary Insights on Premise (IoP) integration for Katello development
# @api private
class katello_devel::iop {
  postgresql::server::pg_hba_rule { 'inventory_db IPV4':
    type        => 'host',
    database    => 'inventory_db',
    user        => 'all',
    address     => '127.0.0.1/32',
    order       => 2,
    auth_method => 'md5',
  }

  postgresql::server::pg_hba_rule { 'inventory_db IPV6':
    type        => 'host',
    database    => 'inventory_db',
    user        => 'all',
    address     => '::1/128',
    order       => 3,
    auth_method => 'md5',
  }

  # Create directory structure for Foreman assets
  file {
    [
      '/var/lib/foreman',
      '/var/lib/foreman/public',
      '/var/lib/foreman/public/assets',
      '/var/lib/foreman/public/assets/apps',
    ]:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
  } ->
  Katello_devel::Git_repo['foreman'] ->
  katello_devel::plugin { 'theforeman/foreman_rh_cloud': } ->
  Katello_devel::Bundle['exec rake db:migrate'] ->
  class { 'iop': }
}

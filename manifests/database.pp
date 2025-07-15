# @summary Database configuration
# @api private
class katello_devel::database {
  $db_password = 'katello'
  $db_username = 'katello'
  $db_adapter = 'postgresql'
  $db_name = 'katello'

  file { "${katello_devel::foreman_dir}/config/database.yml":
    ensure  => file,
    content => template('katello_devel/database.yaml.erb'),
    owner   => $katello_devel::user,
    group   => $katello_devel::group,
    mode    => '0644',
  }

  # Prevents errors if run from /root etc.
  Postgresql_psql {
    cwd => '/',
  }

  class { 'postgresql::server':
    encoding             => 'UTF8',
    pg_hba_conf_defaults => false,
    locale               => 'en_US.utf8',
  }

  postgresql::server::pg_hba_rule { 'local all':
    type        => 'local',
    database    => 'all',
    user        => 'all',
    order       => 1,
    auth_method => 'trust',
  }

  postgresql::server::pg_hba_rule { 'host IPV4':
    type        => 'host',
    database    => 'all',
    user        => 'all',
    address     => '127.0.0.1/32',
    order       => 4,
    auth_method => 'trust',
  }

  postgresql::server::pg_hba_rule { 'host IPV6':
    type        => 'host',
    database    => 'all',
    user        => 'all',
    address     => '::1/128',
    order       => 5,
    auth_method => 'trust',
  }

  postgresql::server::role { $db_username:
    password_hash => $db_password,
    superuser     => true,
  }

  postgresql::server::db { $db_name:
    user     => $db_username,
    password => $db_password,
    owner    => $db_username,
    encoding => 'utf8',
    locale   => 'en_US.utf8',
  }
}

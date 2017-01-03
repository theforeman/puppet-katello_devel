# Handles initialization and setup of the Rails app
class katello_devel::setup {

  if $katello_devel::use_rvm {

    $pidfile = "${::katello_devel::foreman_dir}/tmp/pids/server.pid"

    $seed_env = [
      "SEED_ORGANIZATION=${::katello_devel::initial_organization}",
      "SEED_LOCATION=${::katello_devel::initial_location}",
      "SEED_ADMIN_PASSWORD=${::katello_devel::admin_password}",
    ]

    class { '::katello_devel::rvm': } ->
    katello_devel::rvm_bundle { 'install --without mysql:mysql2 --retry 3': } ->
    katello_devel::rvm_bundle { 'exec rake db:migrate': } ->
    katello_devel::rvm_bundle { 'exec rake db:seed':
      environment => $seed_env,
    } ~>
    katello_devel::rvm_bundle { 'exec rails s -d':
      unless => "/usr/bin/pgrep --pidfile ${pidfile}",
    } ->
    Class['foreman_proxy::register'] ->
    exec { 'destroy rails server':
      command   => "/usr/bin/pkill -9 --pidfile ${pidfile}",
      logoutput => 'on_failure',
      timeout   => '600',
    }
  }

}

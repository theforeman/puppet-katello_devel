# Handles initialization and setup of the Rails app
class katello_devel::setup (
  $foreman_dir = $::katello_devel::foreman_dir,
  $user = $::katello_devel::user,
  $initial_organization = $::katello_devel::initial_organization,
  $initial_location = $::katello_devel::initial_location,
  $admin_password = $::katello_devel::admin_password,
) {
  $pidfile = "${foreman_dir}/tmp/pids/server.pid"

  $seed_env = [
    "SEED_ORGANIZATION=${initial_organization}",
    "SEED_LOCATION=${initial_location}",
    "SEED_ADMIN_PASSWORD=${admin_password}",
  ]

  katello_devel::bundle { 'install --without mysql:mysql2 --retry 3 --jobs 3':
    environment => ['MAKEOPTS=-j'],
  } ->
  katello_devel::bundle { 'exec rake db:migrate': } ->
  katello_devel::bundle { 'exec rake db:seed':
    environment => $seed_env,
  } ~>
  katello_devel::bundle { 'exec rails s -d':
    unless => "/usr/bin/pgrep --pidfile ${pidfile}",
  } ->
  Class['foreman_proxy::register'] ->
  exec { 'destroy rails server':
    command   => "/usr/bin/pkill -9 --pidfile ${pidfile}",
    logoutput => 'on_failure',
    timeout   => '600',
  }
}

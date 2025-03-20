# @summary Handles initialization and setup of the Rails app
# @api private
class katello_devel::setup (
  Stdlib::Absolutepath $foreman_dir = $katello_devel::foreman_dir,
  String $user = $katello_devel::user,
  String $initial_organization = $katello_devel::initial_organization,
  String $initial_location = $katello_devel::initial_location,
  String $admin_password = $katello_devel::admin_password,
  Integer[0] $npm_timeout = $katello_devel::npm_timeout,
) {
  $pidfile = "${foreman_dir}/tmp/pids/server.pid"

  $seed_env = [
    "SEED_ORGANIZATION=${initial_organization}",
    "SEED_LOCATION=${initial_location}",
    "SEED_ADMIN_PASSWORD=${admin_password}",
  ]

  katello_devel::bundle { 'exec rake webpack:compile':
    require => Katello_devel::Bundle['exec npm install'],
    before  => Katello_devel::Bundle['exec rake db:migrate'],
  }

  katello_devel::bundle { 'install --retry 3 --jobs 3 --path .vendor':
    environment => ['MAKEOPTS=-j'],
  } ->
  katello_devel::bundle { 'exec npm install':
    timeout => $npm_timeout,
  } ->
  katello_devel::bundle { 'exec rake db:migrate': } ->
  katello_devel::bundle { 'exec rake db:seed':
    environment => $seed_env,
  }

  if defined(Class['foreman_proxy::register']) {
    katello_devel::bundle { 'exec rails s -d':
      unless    => "/usr/bin/pgrep --pidfile ${pidfile}",
      subscribe => Katello_devel::Bundle['exec rake db:seed'],
    } ->
    Class['foreman_proxy::register'] ->
    exec { 'destroy rails server':
      command   => "/usr/bin/pkill -9 --pidfile ${pidfile}",
      logoutput => 'on_failure',
      timeout   => '600',
    }
  }
}

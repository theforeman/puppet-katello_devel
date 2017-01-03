# Run a bundle command under RVM
define katello_devel::rvm_bundle(
  Array $environment = [],
  $unless = undef,
) {

  exec { "rvm-bundle-${title}":
    cwd         => $::katello_devel::foreman_dir,
    command     => "rvm ${katello_devel::rvm_ruby} do bundle ${title}",
    environment => $environment,
    user        => $::katello_devel::user,
    logoutput   => 'on_failure',
    timeout     => '600',
    path        => '/usr/local/rvm/bin:/usr/bin:/bin:/usr/bin/env',
    unless      => $unless,
  }

}

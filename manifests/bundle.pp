# @summary Run a bundle command
# @api private
define katello_devel::bundle (
  Array[String] $environment = [],
  Variant[Undef, String[1], Array[String[1]]] $unless = undef,
  String $user = $katello_devel::user,
  Stdlib::Absolutepath $cwd = $katello_devel::foreman_dir,
  Integer[0] $timeout = 600,
  Optional[String] $command = undef,
) {
  $bundle_command = pick($command, $title)

  exec { "bundle-${title}":
    command     => "bundle ${bundle_command}",
    environment => $environment + ["HOME=/home/${user}"],
    cwd         => $cwd,
    user        => $user,
    logoutput   => 'on_failure',
    timeout     => $timeout,
    path        => ['/usr/bin', '/bin'],
    unless      => $unless,
  }
}

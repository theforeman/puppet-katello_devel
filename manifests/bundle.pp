# @summary Run a bundle command, possibly under RVM or SCL
# @api private
define katello_devel::bundle (
  Array[String] $environment = [],
  Variant[Undef, String[1], Array[String[1]]] $unless = undef,
  Boolean $use_rvm = $katello_devel::use_rvm,
  String $rvm_ruby = $katello_devel::rvm_ruby,
  Optional[String] $scl_ruby = $katello_devel::scl_ruby,
  Optional[String] $scl_nodejs = $katello_devel::scl_nodejs,
  Optional[String] $scl_postgresql = $katello_devel::scl_postgresql,
  String $user = $katello_devel::user,
  Stdlib::Absolutepath $cwd = $katello_devel::foreman_dir,
  Integer[0] $timeout = 600,
) {
  if $use_rvm {
    include katello_devel::rvm
    Class['katello_devel::rvm'] -> Exec["bundle-${title}"]
    $command = "rvm ${rvm_ruby} do bundle ${title}"
    $path = "/home/${user}/.rvm/bin:/usr/bin:/bin"
  } elsif $scl_ruby {
    $command = "scl enable ${scl_ruby} ${scl_nodejs} ${scl_postgresql} 'bundle ${title}'"
    $path = '/usr/bin:/bin'
  } else {
    $command = "bundle ${title}"
    $path = '/usr/bin:/bin'
  }

  exec { "bundle-${title}":
    command     => $command,
    environment => $environment + ["HOME=/home/${user}"],
    cwd         => $cwd,
    user        => $user,
    logoutput   => 'on_failure',
    timeout     => $timeout,
    path        => $path,
    unless      => $unless,
  }
}

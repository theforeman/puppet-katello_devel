# @summary Generate package name that may or may not be in some SCL
#
# @param package
#   The package name without any SCL prefix
# @param scl
#   An optional SCL name, without a dash as suffix
#
# @return The package name, with SCL prefix if applicable
#
# @example Without SCL
#   katello_devel::package('postgresql-server') == ['postgresql-server']
#
# @example With SCL
#   katello_devel::package('postgresql-server', 'rh-postgresql12') == ['rh-postgresql12-postgresql-server']
function katello_devel::package(String[1] $package, Optional[String[1]] $scl = undef) >> String[1] {
  if $scl {
    "${scl}-${package}"
  } else {
    $package
  }
}

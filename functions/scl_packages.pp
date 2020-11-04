# @summary Generate package names that may or may not be in some SCL
# @param packages
#   The package names without any SCL prefix
# @param scl
#   An optional SCL name, without a dash as suffix
# @return The package names, with SCL prefix if applicable
#
# @example Without SCL
#   katello_devel::scl_packages(['postgresql-server']) == ['postgresql-server']
#
# @example With SCL
#   katello_devel::scl_packages(['postgresql-server'], 'rh-postgresql12') == ['rh-postgresql12-postgresql-server']
function katello_devel::scl_packages(Array[String[1]] $packages, Optional[String[1]] $scl = undef) >> Array[String[1]] {
  if $scl {
    $packages.map |$package| { "${scl}-${package}" }
  } else {
    $packages
  }
}

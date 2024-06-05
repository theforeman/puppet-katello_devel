class { 'foreman::repo':
  repo => 'nightly',
}
class { 'katello::repo':
  repo_version => 'nightly',
}
class { 'candlepin::repo':
  version => 'nightly',
}

user { 'vagrant':
  ensure     => present,
  managehome => true,
}

# Necessary for PostgreSQL EVR extension
yumrepo { "pulpcore":
  baseurl  => "http://yum.theforeman.org/pulpcore/nightly/el\$releasever/x86_64/",
  descr    => "Pulpcore",
  enabled  => true,
  gpgcheck => false,
}

if $facts['os']['release']['major'] == '9' {
  yumrepo { 'crb':
    enabled => true,
  }
} elsif $facts['os']['release']['major'] == '8' {
  package { 'glibc-langpack-en':
    ensure => installed,
  }

  yumrepo { 'powertools':
    enabled => true,
  }
} elsif $facts['os']['release']['major'] == '7' {
  package { 'epel-release':
    ensure => installed,
  }
}

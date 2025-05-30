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

package { ['rubygem-oauth', 'puppet-agent-oauth']:
  ensure  => installed,
  require => Class['foreman::repo'],
}

package { 'podman':
  ensure => latest,
}

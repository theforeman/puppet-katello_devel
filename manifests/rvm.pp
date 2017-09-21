# Setup and create gemset for RVM
class katello_devel::rvm {

  $rvm_install = 'install_rvm.sh'

  package{ ['curl', 'bash']:
    ensure => present,
  }

  file { '/etc/sudoers.d/katello-devel.conf':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('katello_devel/sudoers-dropin.erb'),
  } ->
  file { "/usr/bin/${rvm_install}":
    content => template("katello_devel/${rvm_install}.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
  } ~>
  exec { $rvm_install:
    path    => '/usr/bin:/usr/sbin:/bin',
    creates => "/home/${katello_devel::user}/.rvm/bin/rvm",
    timeout => 900,
    require => [ Package['curl'], Package['bash'], User[$katello_devel::user] ],
  }

}

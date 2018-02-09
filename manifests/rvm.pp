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
  }

  file { "/usr/bin/${rvm_install}":
    content => file("katello_devel/${rvm_install}"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  } ~>
  exec { "/usr/bin/${rvm_install} ${::katello_devel::rvm_ruby} ${::katello_devel::rvm_branch}":
    path        => '/usr/bin:/usr/sbin:/bin',
    user        => $::katello_devel::user,
    environment => "HOME=/home/${::katello_devel::user}",
    creates     => "/home/${::katello_devel::user}/.rvm/bin/rvm",
    timeout     => 900,
    require     => Package['curl', 'bash'],
  }

}

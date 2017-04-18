# Configuration for hammer development
class katello_devel::hammer::config {

  file { ["${katello_devel::deployment_dir}/.hammer/",
          "${katello_devel::deployment_dir}/.hammer/cli.modules.d/"]:
    ensure  => 'directory',
    owner   => $katello_devel::user,
    mode    => '0644'
  }

  katello_devel::hammer::plugin { 'theforeman/hammer-cli': }

  file { "${katello_devel::deployment_dir}/hammer-cli/Gemfile.local":
    ensure  => file,
    content => template("katello_devel/hammer/Gemfile.local"),
    owner   => $katello_devel::user,
    mode    =>  '0644'
  }

  file { "/var/log/hammer":
    ensure => directory,
    owner  => $katello_devel::user,
    group  => $katello_devel::group,
    mode   => '0755'
  }

}

# Configuration for Katello development
class katello_devel::config {
  file { "${katello_devel::deployment_dir}/foreman/bundler.d/Gemfile.local.rb":
    ensure  => file,
    content => template('katello_devel/Gemfile.local.rb.erb'),
    owner   => $katello_devel::user,
    group   => $katello_devel::group,
    mode    => '0644',
  }

  file { "${katello_devel::deployment_dir}/foreman/bundler.d/katello.local.rb":
    ensure  => file,
    content => template('katello_devel/katello.local.rb.erb'),
    owner   => $katello_devel::user,
    group   => $katello_devel::group,
    mode    => '0644',
  }

  file { "${katello_devel::deployment_dir}/foreman/config/settings.yaml":
    ensure  => file,
    content => template('katello_devel/settings.yaml.erb'),
    owner   => $katello_devel::user,
    group   => $katello_devel::group,
    mode    => '0644',
  }

  file { "${katello_devel::deployment_dir}/foreman/config/settings.plugins.d":
    ensure => directory,
    owner  => $katello_devel::user,
    group  => $katello_devel::group,
    mode   => '0755',
  } ->
  file { "${katello_devel::deployment_dir}/foreman/config/settings.plugins.d/katello.yaml":
    ensure  => file,
    content => template('katello/katello.yaml.erb'),
    owner   => $katello_devel::user,
    group   => $katello_devel::group,
    mode    => '0644',
  }
}

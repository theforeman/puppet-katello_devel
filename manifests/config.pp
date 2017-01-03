# Configuration for Katello development
class katello_devel::config {

  file { "${::katello_devel::foreman_dir}/config/settings.yaml":
    ensure  => file,
    content => template('katello_devel/settings.yaml.erb'),
    owner   => $katello_devel::user,
    group   => $katello_devel::group,
    mode    => '0644',
  }

  file { "${::katello_devel::foreman_dir}/config/settings.plugins.d":
    ensure => directory,
    owner  => $katello_devel::user,
    group  => $katello_devel::group,
    mode   => '0755',
  }

  katello_devel::plugin { 'katello/katello':
    settings_template => 'katello_devel/katello.yaml.erb',
  }
  katello_devel::plugin { $katello_devel::extra_plugins: }

}

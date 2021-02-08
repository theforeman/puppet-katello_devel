# @summary Configuration for Katello development
# @api private
class katello_devel::config(
  $foreman_dir = $katello_devel::foreman_dir,
  $user = $katello_devel::user,
  $group = $katello_devel::group,
  $extra_plugins = $katello_devel::extra_plugins,
  String $katello_scm_revision = $katello_devel::katello_scm_revision,
) {

  file { "${foreman_dir}/.env":
    ensure  => file,
    content => template('katello_devel/env.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0644',
  }

  file { "${foreman_dir}/config/settings.yaml":
    ensure  => file,
    content => template('katello_devel/settings.yaml.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0644',
  }

  file { "${foreman_dir}/config/settings.plugins.d":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  katello_devel::plugin { 'katello/katello':
    settings_template => 'katello_devel/katello.yaml.erb',
    scm_revision      => $katello_scm_revision,
  }
  katello_devel::plugin { $extra_plugins: }

}

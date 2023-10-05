# @summary Configuration for Katello development
# @api private
class katello_devel::config (
  Stdlib::Absolutepath $foreman_dir = $katello_devel::foreman_dir,
  String $user = $katello_devel::user,
  String $group = $katello_devel::group,
  Array[Variant[String,Hash]] $extra_plugins = $katello_devel::extra_plugins,
  String $katello_scm_revision = $katello_devel::katello_scm_revision,
  String $rex_scm_revision = $katello_devel::rex_scm_revision,
  Boolean $katello_manage_repo = $katello_devel::katello_manage_repo,
  Boolean $rex_manage_repo = $katello_devel::rex_manage_repo,
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
    manage_repo       => $katello_manage_repo,
  }

  katello_devel::plugin { 'theforeman/foreman_remote_execution':
    scm_revision => $rex_scm_revision,
    manage_repo  => $rex_manage_repo,
  }

  $extra_plugins.each |$plugin| {
    if $plugin =~ Hash {
      katello_devel::plugin { $plugin['name']:
        manage_repo  => $plugin['manage_repo'],
        scm_revision => $plugin['scm_revision'],
      }
    } else {
      katello_devel::plugin { $plugin: }
    }
  }
}

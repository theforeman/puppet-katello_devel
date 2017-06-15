# Setup a plugin
define katello_devel::plugin(
  $settings_template = undef
) {

  $split_array = split($name, '/')
  $github_organization = $split_array[0]
  $plugin = $split_array[1]

  if $settings_template != undef {
    file { "${katello_devel::deployment_dir}/foreman/config/settings.plugins.d/${plugin}.yaml":
      ensure  => file,
      content => template($settings_template),
      owner   => $katello_devel::user,
      group   => $katello_devel::group,
      mode    => '0644',
    }
  }

  file { "${katello_devel::deployment_dir}/foreman/bundler.d/${plugin}.local.rb":
    ensure  => file,
    content => template('katello_devel/plugin.local.rb.erb'),
    owner   => $katello_devel::user,
    group   => $katello_devel::group,
    mode    => '0644',
  }

  katello_devel::git_repo { $plugin:
    source          => $title,
    github_username => $katello_devel::github_username,
  }
}

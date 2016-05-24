# Configuration for hammer development
class katello_devel::hammer::plugin (
  $config_content = undef,
) {

  $split_array = split($name, '/')
  $github_organization = $split_array[0]
  $plugin = $split_array[1]
  $gem_name = regsubst($plugin, '-', '_')

  if $config_content {
    file { "${katello_devel::deployment_dir}/.hammer/cli.modules.d/${plugin}.yml":
      ensure  => file,
      content => $config_content,
      owner   => $katello_devel::user,
      mode    => '0644'
    }
  }

  git_repo { $plugin:
    source          => $title,
    github_username => $katello_devel::github_username,
  }

  file_line { $katello_devel::hammer_gemfile:
    line => "gem '${gem_name}', :path => '../${plugin}'",
    path => "${katello_devel::deployment_dir}/hammer-cli/Gemfile.local"
  }

}

# Setup and configure a git repo
define katello_devel::git_repo(
  String $source,
  String $upstream_remote_name = $katello_devel::upstream_remote_name,
  Optional[String] $github_username = undef,
  Optional[String] $fork_remote_name = $katello_devel::fork_remote_name_real,
  Stdlib::Absolutepath $deployment_dir = $katello_devel::deployment_dir,
  String $dir_owner = $katello_devel::user,
  Boolean $use_ssh_fork = $katello_devel::use_ssh_fork,
) {

  if $github_username != undef and $github_username != '' {
    if $use_ssh_fork {
      $fork_url = "git@github.com:${github_username}/${title}.git"
    } else {
      $fork_url = "https://${github_username}@github.com/${github_username}/${title}.git"
    }

    $sources = {
      $upstream_remote_name => "https://github.com/${source}.git",
      $fork_remote_name => $fork_url,
    }
  } else {
    $sources = {$upstream_remote_name => "https://github.com/${source}.git"}
  }

  vcsrepo { "${deployment_dir}/${title}":
    ensure   => present,
    provider => git,
    remote   => $upstream_remote_name,
    source   => $sources,
    user     => $dir_owner,
  } ->
	exec { "git config --add remote.${$upstream_remote_name}.fetch '+refs/pull/*/head:refs/remotes/${upstream_remote_name}/pr/*'":
    path => '/usr/bin:/usr/sbin:/bin',
    user => $::katello_devel::user,
	}

}

# @summary Setup and configure a git repo
# @api private
define katello_devel::git_repo (
  String $source,
  String $upstream_remote_name = $katello_devel::upstream_remote_name,
  Optional[String] $github_username = undef,
  Optional[String] $fork_remote_name = $katello_devel::fork_remote_name_real,
  Boolean $clone_from_fork = $katello_devel::clone_from_fork,
  Stdlib::Absolutepath $deployment_dir = $katello_devel::deployment_dir,
  String $dir_owner = $katello_devel::user,
  Boolean $use_ssh_fork = $katello_devel::use_ssh_fork,
  Optional[String] $revision = undef,
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
    $initial_remote = $clone_from_fork ? {
      true    => $fork_remote_name,
      default => $upstream_remote_name,
    }
  } else {
    if $clone_from_fork {
      fail('Tried to use clone_from_fork without specifying github_username to use as fork!')
    }
    $sources = { $upstream_remote_name => "https://github.com/${source}.git" }
    $initial_remote = $upstream_remote_name
  }

  vcsrepo { "${deployment_dir}/${title}":
    ensure   => present,
    provider => git,
    remote   => $initial_remote,
    source   => $sources,
    user     => $dir_owner,
    revision => $revision,
  }
}

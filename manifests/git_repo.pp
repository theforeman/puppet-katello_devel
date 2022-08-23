# @summary Setup and configure a git repo
# @api private
define katello_devel::git_repo (
  String $source,
  String $upstream_remote_name = $katello_devel::upstream_remote_name,
  Optional[String] $github_username = undef,
  Optional[String] $fork_remote_name = $katello_devel::fork_remote_name_real,
  Stdlib::Absolutepath $deployment_dir = $katello_devel::deployment_dir,
  String $dir_owner = $katello_devel::user,
  Boolean $use_ssh_fork = $katello_devel::use_ssh_fork,
  Optional[String] $revision = undef,
  Optional[Hash[String, String, 1]] $custom_remotes = undef,
) {
  if $custom_remotes != undef {
    $remote_name = $custom_remotes.keys()[0]
    $sources     = $custom_remotes
  } else {
    $remote_name = $upstream_remote_name
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
      $sources = { $upstream_remote_name => "https://github.com/${source}.git" }
    }
  }

  vcsrepo { "${deployment_dir}/${title}":
    ensure   => present,
    provider => git,
    remote   => $remote_name,
    source   => $sources,
    user     => $dir_owner,
    revision => $revision,
  }
}

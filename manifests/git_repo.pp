# Setup and configure a git repo
define katello_devel::git_repo(
  String $source,
  $github_username = undef,
  $upstream_remote_name = $katello_devel::upstream_remote_name,
) {

  if $github_username != undef {
    if $katello_devel::use_ssh_fork {
      $fork_url = "git@github.com:${github_username}/${title}.git"
    } else {
      $fork_url = "https://${github_username}@github.com/${github_username}/${title}.git"
    }

    $sources = {"${upstream_remote_name}" => "https://github.com/${source}.git", "${katello_devel::fork_remote_name_real}" => $fork_url}
  } else {
    $sources = {"${upstream_remote_name}" => "https://github.com/${source}.git"}
  }

  vcsrepo { "${katello_devel::deployment_dir}/${title}":
    ensure   => present,
    provider => git,
    remote   => $upstream_remote_name,
    source   => $sources,
    user     => $katello_devel::user,
  }

}

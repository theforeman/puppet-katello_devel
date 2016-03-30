# Katello Development Install
class katello_devel::install {

  package{ ['pulp-katello', 'libvirt-devel', 'sqlite-devel', 'postgresql-devel', 'libxslt-devel', 'libxml2-devel', 'git']:
    ensure => present,
  }

  git_repo { 'foreman':
    source          => 'theforeman/foreman',
    github_username => $katello_devel::github_username,
  }

}

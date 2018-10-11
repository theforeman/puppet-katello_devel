# Katello Development Install
class katello_devel::install {

  package{ ['libvirt-devel', 'sqlite-devel', 'postgresql-devel', 'libxslt-devel', 'systemd-devel', 'libxml2-devel', 'git', 'npm', 'libcurl-devel', 'gcc-c++', 'libstdc++']:
    ensure => present,
  }

  if $katello_devel::use_scl_ruby {
    package { ["${katello_devel::scl_ruby}-ruby-devel", "${katello_devel::scl_ruby}-rubygem-bundler"]:
      ensure => present,
    }
  }

  katello_devel::git_repo { 'foreman':
    source          => 'theforeman/foreman',
    github_username => $katello_devel::github_username,
  }

}

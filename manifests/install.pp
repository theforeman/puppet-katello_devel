# Katello Development Install
class katello_devel::install {

  package{ ['cyrus-sasl-plain', 'libvirt-devel', 'sqlite-devel', 'rh-postgresql12-postgresql-devel', 'libxslt-devel', 'systemd-devel', 'libxml2-devel', 'git', "${katello_devel::scl_nodejs}-npm", 'libcurl-devel', 'gcc-c++', 'libstdc++']:
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

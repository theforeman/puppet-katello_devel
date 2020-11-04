# @summary Katello Development Install
# @api private
class katello_devel::install {

  package{ [
      'cyrus-sasl-plain',
      'libvirt-devel',
      'sqlite-devel',
      'libxslt-devel',
      'systemd-devel',
      'libxml2-devel',
      'git',
      'libcurl-devel',
      'gcc-c++',
      'libstdc++',
      'katello-selinux',
    ]:
      ensure => present,
  }

  package { katello_devel::scl_packages(['postgresql-devel', 'postgresql-debversion', 'postgresql-evr'], $katello_devel::scl_postgresql):
    ensure => present,
  }

  package { katello_devel::scl_packages(['npm'], $katello_devel::scl_nodejs):
    ensure => present,
  }

  unless $katello_devel::use_rvm {
    package { katello_devel::scl_packages(['ruby-devel', 'rubygem-bundler'], $katello_devel::scl_ruby):
      ensure => present,
    }
  }

  katello_devel::git_repo { 'foreman':
    source          => 'theforeman/foreman',
    github_username => $katello_devel::github_username,
  }

}

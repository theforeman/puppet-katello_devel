# @summary Katello Development Install
# @api private
class katello_devel::install {

  package{ [
      'cyrus-sasl-plain',
      'libvirt-devel',
      'sqlite-devel',
      katello_devel::package('postgresql-devel', $katello_devel::scl_postgresql),
      'libxslt-devel',
      'systemd-devel',
      'libxml2-devel',
      'git',
      katello_devel::package('npm', $katello_devel::scl_nodejs),
      'libcurl-devel',
      'gcc-c++',
      'libstdc++',
      katello_devel::package('postgresql-debversion', $katello_devel::scl_postgresql),
      katello_devel::package('postgresql-evr', $katello_devel::scl_postgresql),
      'katello-selinux',
      'make',
      katello_devel::package('ruby-devel', $katello_devel::scl_ruby),
      katello_devel::package('rubygem-bundler', $katello_devel::scl_ruby),
    ]:
      ensure => present,
  }

  katello_devel::git_repo { 'foreman':
    source          => 'theforeman/foreman',
    github_username => $katello_devel::github_username,
  }

}

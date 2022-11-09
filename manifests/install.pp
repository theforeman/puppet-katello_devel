# @summary Katello Development Install
# @api private
class katello_devel::install {
  package { 'nodejs':
    ensure   => $katello_devel::modulestream_nodejs,
    provider => 'dnfmodule',
    before   => Package['npm'],
  }

  package { [
      'libvirt-devel',
      'sqlite-devel',
      'postgresql-devel',
      'libxslt-devel',
      'systemd-devel',
      'libxml2-devel',
      'git',
      'npm',
      'libcurl-devel',
      'gcc-c++',
      'libstdc++',
      'postgresql-debversion',
      'postgresql-evr',
      'katello-selinux',
      'make',
      'ruby-devel',
      'rubygem-bundler',
      'qpid-proton-c-devel',
    ]:
      ensure => present,
  }

  if $katello_devel::foreman_manage_repo {
    katello_devel::git_repo { 'foreman':
      source          => 'theforeman/foreman',
      github_username => $katello_devel::github_username,
      revision        => $katello_devel::foreman_scm_revision,
    }
  }
}

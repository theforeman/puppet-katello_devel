# @summary Katello Development Install
# @api private
class katello_devel::install {
  if $facts['os']['release']['major'] == '9' {
    if $facts['os']['name'] == 'RedHat' {
      rh_repo { "codeready-builder-for-rhel-${facts['os']['release']['major']}-${facts['os']['architecture']}-rpms":
        ensure => present,
        before => Package['libvirt-devel'],
      }
    } else {
      yumrepo { 'crb':
        enabled => true,
        before  => Package['libvirt-devel'],
      }
    }
  }

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
      'katello-selinux',
      'make',
      'ruby-devel',
      'rubygem-bundler',
      'rubygem-irb',
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

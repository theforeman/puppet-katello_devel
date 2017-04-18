# == Class: puppet-hammer_devel
#
# Install and configure hammer-cli-katello for development
#
class katello_devel::hammer () {

  class { 'katello_devel::hammer::config': } ~>
  katello_devel::hammer::plugin { 'theforeman/hammer-cli-foreman':
    config_content => template('katello_devel/hammer/foreman.yml'),
  } ~>
  katello_devel::hammer::plugin { 'katello/hammer-cli-katello':
    config_content => template('katello_devel/hammer/katello.yml'),
  } ~>
  katello_devel::hammer::plugin { 'theforeman/hammer-cli-foreman-tasks':
    config_content => template('katello_devel/hammer/katello.yml'),
  }

}

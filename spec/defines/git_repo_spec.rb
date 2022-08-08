require 'spec_helper'

describe 'katello_devel::git_repo' do
  let :title do
    'puppet-katello_devel'
  end

  context 'with explicit parameters' do
    context 'with a fork' do
      let :params do {
        source: 'theforeman/puppet-katello_devel',
        upstream_remote_name: 'upstream',
        github_username: 'user',
        fork_remote_name: 'personal',
        clone_from_fork: false,
        deployment_dir: '/tmp',
        dir_owner: 'user',
        use_ssh_fork: true,
      } end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_vcsrepo('/tmp/puppet-katello_devel')
          .with_ensure('present')
          .with_provider('git')
          .with_remote('upstream')
          .with_source(
            'personal' => 'git@github.com:user/puppet-katello_devel.git',
            'upstream' => 'https://github.com/theforeman/puppet-katello_devel.git'
          )
          .with_user('user')
      end
    end

    context 'clone from fork' do
      let :params do {
        source: 'theforeman/puppet-katello_devel',
        upstream_remote_name: 'upstream',
        github_username: 'user',
        fork_remote_name: 'personal',
        clone_from_fork: true,
        deployment_dir: '/tmp',
        dir_owner: 'user',
        use_ssh_fork: true,
      } end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_vcsrepo('/tmp/puppet-katello_devel')
          .with_ensure('present')
          .with_provider('git')
          .with_remote('personal')
          .with_source(
            'personal' => 'git@github.com:user/puppet-katello_devel.git',
            'upstream' => 'https://github.com/theforeman/puppet-katello_devel.git'
          )
          .with_user('user')
      end
    end

    context 'without a fork' do
      let :params do {
        source: 'theforeman/puppet-katello_devel',
        upstream_remote_name: 'upstream',
        fork_remote_name: nil,
        clone_from_fork: false,
        deployment_dir: '/tmp',
        dir_owner: 'user',
        use_ssh_fork: true,
      } end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_vcsrepo('/tmp/puppet-katello_devel')
          .with_ensure('present')
          .with_provider('git')
          .with_remote('upstream')
          .with_source('upstream' => 'https://github.com/theforeman/puppet-katello_devel.git')
          .with_user('user')
      end
    end
  end
end

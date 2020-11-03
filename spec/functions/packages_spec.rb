require 'spec_helper'

describe 'katello_devel::package' do
  describe 'without scl' do
    it { is_expected.to run.with_params('').and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params('foo').and_return('foo') }
  end

  describe 'with scl' do
    it { is_expected.to run.with_params('', 'myscl').and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params('foo', 'myscl').and_return('myscl-foo') }
  end
end

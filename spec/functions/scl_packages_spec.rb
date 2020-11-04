require 'spec_helper'

describe 'katello_devel::scl_packages' do
  describe 'without scl' do
    it { is_expected.to run.with_params([]).and_return([]) }
    it { is_expected.to run.with_params(['foo']).and_return(['foo']) }
    it { is_expected.to run.with_params(['foo', 'bar']).and_return(['foo', 'bar']) }
  end

  describe 'with scl' do
    it { is_expected.to run.with_params([], 'myscl').and_return([]) }
    it { is_expected.to run.with_params(['foo'], 'myscl').and_return(['myscl-foo']) }
    it { is_expected.to run.with_params(['foo', 'bar'], 'myscl').and_return(['myscl-foo', 'myscl-bar']) }
  end
end

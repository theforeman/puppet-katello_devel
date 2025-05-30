require 'spec_helper_acceptance'

describe 'Scenario: install katello_devel' do
  let(:manifest) do
    <<-PUPPET
      class { 'katello_devel':
        user       => 'vagrant',
        enable_iop => true,
      }
    PUPPET
  end

  it 'applies with no errors' do
    apply_manifest(manifest, catch_failures: true)
  end
end

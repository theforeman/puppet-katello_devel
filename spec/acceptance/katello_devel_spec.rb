require 'spec_helper_acceptance'

describe 'Scenario: install katello_devel' do
  let(:manifest) do
    <<-PUPPET
      class { 'katello_devel':
        user => 'vagrant',
      }
    PUPPET
  end

  it 'applies with no errors' do
    apply_manifest(manifest, catch_failures: true)
  end

  [
    'httpd',
    'tomcat',
  ].each do |service_name|
    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  describe port(80) do
    it { is_expected.to be_listening }
  end

  describe port(443) do
    it { is_expected.to be_listening }
  end

  describe file("/usr/share/tomcat/conf/cert-users.properties") do
    its(:content) { should eq("katelloUser=CN=#{fact('fqdn')}, OU=PUPPET, O=FOREMAN, ST=North Carolina, C=US\n") }
  end
end

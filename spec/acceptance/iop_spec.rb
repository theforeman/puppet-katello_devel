require 'spec_helper_acceptance'

describe 'Scenario: install katello_devel with IoP' do
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

  describe file('/etc/httpd/conf.d/05-foreman-ssl.conf') do
    it { is_expected.to be_file }
    its(:content) { should match /ProxyPass \/assets\/apps !/ }
  end
end

describe 'Scenario: install katello_devel with IoP proxy assets apps' do
  let(:manifest) do
    <<-PUPPET
      class { 'katello_devel':
        user                  => 'vagrant',
        enable_iop            => true,
        iop_proxy_assets_apps => true,
      }
    PUPPET
  end

  it 'applies with no errors' do
    apply_manifest(manifest, catch_failures: true)
  end

  describe file('/etc/httpd/conf.d/05-foreman-ssl.d/katello-iop-assets.conf') do
    it { is_expected.to be_file }
    its(:content) { should match /ProxyPass \/assets\/apps http:\/\/localhost:8002\// }
  end
end

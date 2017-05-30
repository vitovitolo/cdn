require 'serverspec'

set :backend, :exec

#Test every package are installed, enabled and runnning
packages_list = [ "haproxy", "varnish", "nginx-extras" ]

packages_list.each do |package|
  describe package(package) do
    it { should be_installed }
  end
end

describe service('haproxy') do
  it { should be_enabled }
  it { should be_running }
end

#Test localhost haproxy, nginx and varnish listen ports
port_list = [ 8080, 8888, 8000, 6081, 6082 ]

port_list.each do |port|
  describe port(port) do
    it { should be_listening.on('127.0.0.1').with('tcp') }
  end
end

#describe file('/var/log/haprox_access.log') do
#  it { should be_file }
#  it { should be_readable.by('others') }
#end

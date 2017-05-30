require 'serverspec'

describe package('haproxy') do
  it { should be_installed }
end

describe 'proxy' do
  it 'responds on port 80' do
    expect(port 80).to be_listening 'tcp'
  end
end

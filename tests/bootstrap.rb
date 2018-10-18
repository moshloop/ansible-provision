describe file('/etc/environment') do
  its('content') { should match /role=test/ }
end
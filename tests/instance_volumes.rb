['/mnts/d1', '/mnt/nvm'].each do |m|
    describe mount(m) do
    it { should be_mounted }
    end
end

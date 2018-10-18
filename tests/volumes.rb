['/mnts/d1', '/mnts/d2', '/mnts/d3', '/mnts/d4', '/mnt/nvm'].each do |m|
    describe mount(m) do
    it { should be_mounted }
    end
end

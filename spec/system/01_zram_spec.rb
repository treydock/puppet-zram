require 'spec_helper_system'

describe 'zram class:' do
  context 'should run successfully' do
    pp = "class { 'zram': }"
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
    end
  end
  
  context "should manage zram service" do
    describe service('zram') do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context "should load zram module" do
    describe kernel_module('zram') do
      it { should be_loaded }
    end
  end
  
  context 'should create 2 zram devices using disksize 64MB' do
    pp = <<-EOS
      class { 'zram': 
        device_disksize => 67108864,
        num_devices     => 2,
      }
    EOS
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
    end
    
    describe file('/sys/block/zram0/disksize') do 
      it { should contain '67108864' }
    end
    
    describe file('/sys/block/zram1/disksize') do 
      it { should contain '67108864' }
    end
    
    describe file('/sys/block/zram2') do 
      it { should_not be_directory }
    end
  end
end

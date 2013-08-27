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
end

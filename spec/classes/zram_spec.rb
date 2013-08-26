require 'spec_helper'

describe 'zram' do
  include_context :default_facts

  let :facts do
    default_facts
  end

  it { should create_class('zram') }
  it { should contain_class('zram::params') }
  
  it do
    should contain_file('/etc/default/zram').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'before'  => 'File[/usr/sbin/zramstart]',
    })
  end
  
  it do
    should contain_file('/etc/default/zram') \
      .with_content(/^FACTOR=50$/) \
      .with_content(/^NUM_DEVICES=1$/) \
      .with_content(/^SWAP=1$/) \
      .with_content(/^ZFS=0$/) \
      .with_content(/^ZPOOL_NAME=tank$/)
  end
  
  it do
    should contain_file('/usr/sbin/zramstart').with({
      'ensure'  => 'present',
      'source'  => 'puppet:///modules/zram/zramstart',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'before'  => 'File[/usr/sbin/zramstop]',
    })
  end

  it do
    should contain_file('/usr/sbin/zramstop').with({
      'ensure'  => 'present',
      'source'  => 'puppet:///modules/zram/zramstop',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'before'  => 'File[/etc/init.d/zram]',
    })
  end

  it do
    should contain_file('/etc/init.d/zram').with({
      'ensure'  => 'present',
      'source'  => 'puppet:///modules/zram/zram.init',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'before'  => 'Service[zram]',
    })
  end
  
  it do
    should contain_service('zram').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'false',
      'hasrestart'  => 'true',
      'status'      => 'lsmod | grep -q "^zram"',
    })
  end

  it do
    should contain_file('/usr/sbin/zramstat').with({
      'ensure'  => 'present',
      'source'  => 'puppet:///modules/zram/zramstat',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
    })
  end

  context 'with factor => 25' do
    let(:params) {{ :factor => 25 }}
    
    it { should contain_file('/etc/default/zram').with_content(/^FACTOR=25$/) }
  end
  
  context 'with num_devices => 2' do
    let(:params) {{ :num_devices => 2 }}
    
    it { should contain_file('/etc/default/zram').with_content(/^NUM_DEVICES=2$/) }
  end

  context 'with fact processorcount => 4' do
    let(:params) {{  }}
    
    let(:facts) { default_facts.merge({ :processorcount => 4}) }
    
    it { should contain_file('/etc/default/zram').with_content(/^NUM_DEVICES=4$/) }
  end

  context 'with swap => false and zfs => true' do
    let(:params) {{ :swap => false, :zfs => true }}
    
    it { should contain_file('/etc/default/zram').with_content(/^SWAP=0$/) }
    it { should contain_file('/etc/default/zram').with_content(/^ZFS=1$/) }
  end
  
  context 'with swap => true and zfs => true' do
    let(:params) {{ :swap => true, :zfs => true }}
    it { expect { should contain_file('/etc/default/zram') }.to raise_error(Puppet::Error, /zfs and swap can not both be true/) }
  end
  
  context 'with zpool_name => foo' do
    let(:params) {{ :zpool_name => 'foo' }}
    
    it { should contain_file('/etc/default/zram').with_content(/^ZPOOL_NAME=foo$/) }
  end
end

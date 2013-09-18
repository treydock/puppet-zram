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
  
  it 'should set /etc/default/zram values' do
    verify_contents(subject, '/etc/default/zram', [
      'FACTOR=50',
      'DEVICE_DISKSIZE=0',
      'NUM_DEVICES=1',
      'SWAP=1',
      'ZFS=0',
      'ZPOOL_NAME=tank',
    ])
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
      'before'  => 'File[/usr/sbin/zramstat]',
    })
  end

  it do
    should contain_file('/usr/sbin/zramstat').with({
      'ensure'  => 'present',
      'source'  => 'puppet:///modules/zram/zramstat',
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
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'status'      => nil,
      'restart'     => nil,
      'subscribe'   => 'File[/etc/default/zram]',
    })
  end

  context 'with factor => 25' do
    let(:params) {{ :factor => 25 }}
    
    it 'should set FACTOR=25' do
      verify_contents(subject, '/etc/default/zram', ['FACTOR=25'])
    end
  end

  context 'with device_disksize => 1024' do
    let(:params) {{ :device_disksize => 1024 }}
    
    it 'should set DEVICE_DISKSIZE=1024' do
      verify_contents(subject, '/etc/default/zram', ['DEVICE_DISKSIZE=1024'])
    end
  end
  
  context 'with device_disksize => false' do
    let(:params) {{ :device_disksize => false }}
    
    it 'should set DEVICE_DISKSIZE=0' do
      verify_contents(subject, '/etc/default/zram', ['DEVICE_DISKSIZE=0'])
    end
  end
  
  context 'with num_devices => 2' do
    let(:params) {{ :num_devices => 2 }}
    
    it 'should set NUM_DEVICES=25' do
      verify_contents(subject, '/etc/default/zram', ['NUM_DEVICES=2'])
    end
  end

  context 'with fact processorcount => 4' do
    let(:params) {{  }}
    let(:facts) { default_facts.merge({ :processorcount => 4}) }
    
    it 'should set NUM_DEVICES=4' do
      verify_contents(subject, '/etc/default/zram', ['NUM_DEVICES=4'])
    end
  end

  context 'with swap => false and zfs => true' do
    let(:params) {{ :swap => false, :zfs => true }}
    
    it 'should set SWAP=0 and ZFS=1' do
      verify_contents(subject, '/etc/default/zram', [
        'SWAP=0',
        'ZFS=1',
      ])
    end
  end
  
  context 'with swap => true and zfs => true' do
    let(:params) {{ :swap => true, :zfs => true }}
    it { expect { should contain_file('/etc/default/zram') }.to raise_error(Puppet::Error, /zfs and swap can not both be true/) }
  end
  
  context 'with zpool_name => foo' do
    let(:params) {{ :zpool_name => 'foo' }}
    
    it 'should set ZPOOL_NAME=25' do
      verify_contents(subject, '/etc/default/zram', ['ZPOOL_NAME=foo'])
    end
  end
  
  context 'with service_autorestart => false' do
    let(:params) {{ :service_autorestart => false }}
    
    it { should contain_service('zram').with_subscribe(nil) }
  end

  context 'with service_ensure => "stopped"' do
    let(:params) {{ :service_ensure => 'stopped' }}
    
    it { should contain_service('zram').with_ensure('stopped') }
  end

  context 'with service_ensure => "undef"' do
    let(:params) {{ :service_ensure => 'undef' }}
    
    it { should contain_service('zram').without_ensure }
  end

  context 'with service_enable => "true"' do
    let(:params) {{ :service_enable => 'true' }}
    
    it { should contain_service('zram').with_enable('true') }
  end

  context 'with service_enable => "false"' do
    let(:params) {{ :service_enable => 'false' }}
    
    it { should contain_service('zram').with_enable('false') }
  end

  context 'with service_enable => false' do
    let(:params) {{ :service_enable => false }}
    
    it { should contain_service('zram').with_enable('false') }
  end

  context 'with service_enable => "undef"' do
    let(:params) {{ :service_enable => 'undef' }}
    
    it { should contain_service('zram').without_enable }
  end
end

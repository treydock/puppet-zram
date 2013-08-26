# == Class: zram
#
# Manage the zram Kernel module.
#
# === Parameters
#
# [*service_ensure*]
#   Default: $zram::params::service_ensure
#
# [*service_enable*]
#   Default: $zram::params::service_enable
#
# [*factor*]
#   Default: 50
#
# [*num_devices*]
#   Default: $zram::params::num_devices
#
# [*swap*]
#   Default: true
#
# [*zfs*]
#   Default: false
#
# [*zpool_name*]
#   Default: tank
#
# === Examples
#
#  Create zram for use with swap
#
#  class { 'zram': }
#
#  Create zram devices for use with ZFS cache
#
#  class { 'zram':
#    swap => false,
#    zfs  => true,
#  }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zram (
  $service_ensure = $zram::params::service_ensure,
  $service_enable = $zram::params::service_enable,
  $factor       = '50',
  $num_devices  = $zram::params::num_devices,
  $swap         = true,
  $zfs          = false,
  $zpool_name   = 'tank'
) inherits zram::params {

  $swap_real = str2bool($swap) ? {
    true  => 1,
    false => 0,
  }

  $zfs_real = str2bool($zfs) ? {
    true  => 1,
    false => 0,
  }

  if $zfs_real == 1 and $swap_real == 1 {
    fail("Module ${module_name}: zfs and swap can not both be true")
  }

  file { $zram::params::config_path:
    ensure  => present,
    content => template('zram/zram.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }->
  file { $zram::params::zramstart_path:
    ensure  => present,
    source  => 'puppet:///modules/zram/zramstart',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }->
  file { $zram::params::zramstop_path:
    ensure  => present,
    source  => 'puppet:///modules/zram/zramstop',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }->
  file { $zram::params::service_path:
    ensure  => present,
    source  => 'puppet:///modules/zram/zram.init',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => Service['zram'],
  }

  service { 'zram':
    ensure      => $service_ensure,
    enable      => $service_enable,
    name        => $zram::params::service_name,
    hasstatus   => $zram::params::service_hasstatus,
    hasrestart  => $zram::params::service_hasrestart,
    status      => $zram::params::service_status,
  }

  file { $zram::params::zramstat_path:
    ensure  => present,
    source  => 'puppet:///modules/zram/zramstat',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
}

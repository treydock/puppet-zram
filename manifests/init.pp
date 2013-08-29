# == Class: zram
#
# Manage the zram Kernel module.
#
# === Parameters
#
# [*service_name*]
#   Default: zram
#
# [*service_ensure*]
#   Default: running
#
# [*service_enable*]
#   Default: true
#
# [*service_autorestart*]
#   Boolean.  Defines if the zram service will
#   be restarted when configurations change.
#   Default: true
#
# [*config_path*]
#   Default: /etc/default/zram
#
# [*factor*]
#   String or Integer. The percent of RAM to use for zram.
#   This amount is divided evenly between the zram devices.
#   Default: 50
#
# [*device_disksize*]
#   Integer. Sets disksize in bytes of each zram device.
#   Overrides the factor parameter, and can be disabled by setting to 0.
#   Default: 0
#
# [*num_devices*]
#   String or Integer. Number of zram devices to create.
#   Default: $::processorcount
#
# [*swap*]
#   Boolean. Define if the zram devices should be assigned to swap.
#   This option cannot be used with zfs set to true.
#   Default: true
#
# [*zfs*]
#   Boolean. Define if the zram devices should be assigned to zpool cache.
#   This option cannot be used with swap set to true.
#   Default: false
#
# [*zpool_name*]
#   String. Sets the zpool that the zram devices will be assigned as cache.
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
#  Create zram devices for ZFS each with a disksize of 1GB
#
#  class { 'zram':
#    device_disksize  => 1073741824,
#    swap             => false,
#    zfs              => true,
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
  $service_name         = $zram::params::service_name,
  $service_ensure       = $zram::params::service_ensure,
  $service_enable       = $zram::params::service_enable,
  $service_autorestart  = $zram::params::service_autorestart,
  $config_path          = $zram::params::config_path,
  $factor               = $zram::params::factor,
  $device_disksize      = $zram::params::device_disksize,
  $num_devices          = $zram::params::num_devices,
  $swap                 = $zram::params::swap,
  $zfs                  = $zram::params::zfs,
  $zpool_name           = $zram::params::zpool_name
) inherits zram::params {


  $service_autorestart_real = $service_autorestart ? {
    true  => File[$config_path],
    false => undef,
  }

  $device_disksize_real = $device_disksize ? {
    false   => 0,
    default => $device_disksize,
  }

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

  file { $config_path:
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
  file { $zram::params::zramstat_path:
    ensure  => present,
    source  => 'puppet:///modules/zram/zramstat',
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
    name        => $service_name,
    hasstatus   => true,
    hasrestart  => true,
    subscribe   => $service_autorestart_real,
  }

}

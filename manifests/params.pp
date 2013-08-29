# == Class: zram::params
#
# The zram configuration settings.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf# == Class: zram
#
class zram::params {

  $service_autorestart  = true
  $factor               = 50
  $device_disksize      = 0
  $num_devices  = $::processorcount ? {
    undef   => 1,
    default => $::processorcount,
  }
  $swap                 = true
  $zfs                  = false
  $zpool_name           = 'tank'

  case $::osfamily {
    'RedHat': {
      $config_path        = '/etc/default/zram'
      $zramstart_path     = '/usr/sbin/zramstart'
      $zramstop_path      = '/usr/sbin/zramstop'
      $zramstat_path      = '/usr/sbin/zramstat'
      $service_path       = '/etc/init.d/zram'
      $service_name       = 'zram'
      $service_ensure     = running
      $service_enable     = true
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
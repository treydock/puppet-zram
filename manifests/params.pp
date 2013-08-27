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
# Copyright 2013 Trey Dockendorf
#
class zram::params {

  $num_devices  = $::processorcount ? {
    undef   => 1,
    default => $::processorcount,
  }

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
      $service_hasstatus  = true
      $service_hasrestart = true
      $service_status     = undef
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
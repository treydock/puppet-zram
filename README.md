# puppet-zram [![Build Status](https://travis-ci.org/treydock/puppet-zram.png)](https://travis-ci.org/treydock/puppet-zram)

Puppet module to configure the zram Kernel module.

## Support

* RedHat based distributions

Tested using CentOS 6.4 and Scientific Linux 6.4

## Reference

### Class: zram

Default module configuration.  Creates one zram device per CPU for swap, using 50% of the host's RAM.

    class { 'zram': }

This is an example of using this module for ZFS L2ARC caching

    class { 'zram':
      swap        => false,
      zfs         => true,
      zpool_name  => 'tank',
    }

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake ci

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake spec:system

## Further Information

* [FedoraZram](https://github.com/mystilleef/FedoraZram)
* [RHEL6.3_ZRAM_SCRIPTS](https://github.com/michaelschapira/RHEL6.3_ZRAM_Scripts)

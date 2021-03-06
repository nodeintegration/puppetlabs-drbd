#
# This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
class drbd(
  $service_enable = true,
  $utils_package  = $drbd::params::utils_package,
  $kmod_package   = $drbd::params::kmod_package,
) inherits drbd::params {

  include drbd::service

  package { $utils_package:
    ensure => present,
    alias  => 'drbd-utils',
  }
  # Some distributions do not have drbd in mainline kernel (Redhat for example)
  #  and require a kernel module package
  if $kmod_package {
    package { $kmod_package:
      ensure => present,
      alias  => 'kmod-drbd',
      before => Package['drbd-utils'],
    }
  }

  # ensure that the kernel module is loaded
  exec { 'modprobe drbd':
    path    => ['/bin/', '/sbin/'],
    unless  => 'grep -qe \'^drbd \' /proc/modules',
    require => Package['drbd-utils'], # This is incase we need a kmod package which is run before the utils package if needed
  }

  File {
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['drbd-utils'],
    notify  => Class['drbd::service'],
  }

  # this file just includes other files
  file { '/etc/drbd.conf':
    source  => 'puppet:///modules/drbd/drbd.conf',
  }

  file { '/etc/drbd.d/global_common.conf':
    content => template('drbd/global_common.conf.erb')
  }

  # only allow files managed by puppet in this directory.
  file { '/etc/drbd.d':
    ensure  => directory,
    mode    => '0644',
    purge   => true,
    recurse => true,
    force   => true,
    require => Package['drbd-utils'],
  }

#  exec { "fix_drbd_runlevel":
#    command     =>  "update-rc.d -f drbd remove && update-rc.d drbd defaults 19",
#    path        => [ "/sbin", "/usr/sbin", "/usr/bin/" ],
#    unless      => "stat /etc/rc3.d/S19drbd",
#    require => Package['drbd8-utils']
#  }
}

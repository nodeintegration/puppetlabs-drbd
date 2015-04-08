class drbd::service {
  @service { 'drbd':
    ensure  => running,
    enable  => $drbd::service_enable,
    require => Package['drbd-utils'],
    restart => 'service drbd reload',
  }
}

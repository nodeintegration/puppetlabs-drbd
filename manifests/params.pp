class drbd::params {
  $utils_package = $::osfamily ? {
    'RedHat' => 'drbd84-utils',
    default  => 'drbd8-utils',
  }

  $kmod_package = $::osfamily ? {
    'RedHat' => 'kmod-drbd84',
    default  => undef,
  }
}

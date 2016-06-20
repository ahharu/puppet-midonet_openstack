class midonet_openstack::profile::repos{
  case $::osfamily {
    'Debian': {
      include ::apt
      class { '::openstack_extras::repo::debian::ubuntu':
      release         => 'mitaka',
      package_require => true,
    }
    # Ceph is both packaged on UCA & ceph.com
    # Official packages are on ceph.com so we want to make sure
    # Ceph will be installed from there.
    apt::pin { 'ceph':
      priority => 1001,
      origin   => 'download.ceph.com',
    }
  }
  'RedHat': {
    class { '::openstack_extras::repo::redhat::redhat':
      release           => 'mitaka',
      manage_epel       => false,
      centos_mirror_url => $::nodepool_mirror_host,
    }
  }
  default: {
    fail("Unsupported osfamily (${::osfamily})")
  }
}

# On CentOS, deploy Ceph using SIG repository and get rid of EPEL.
# https://wiki.centos.org/SpecialInterestGroup/Storage/
if $::operatingsystem == 'CentOS' {
  $enable_sig  = true
  $enable_epel = false
  } else {
    $enable_sig  = false
    $enable_epel = true
  }

  class { '::ceph::repo':
  enable_sig  => $enable_sig,
  enable_epel => $enable_epel,
}
}

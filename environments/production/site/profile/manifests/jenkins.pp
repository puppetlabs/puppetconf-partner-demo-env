class profile::jenkins {
  
  class { 'jenkins':
    configure_firewall => true,
  }

}


node_group { 'PE Infrastructure':
  classes     => {
    'puppet_enterprise'              => {
      'use_application_services'     => true,
      'mcollective_middleware_hosts' => ["master.vm"],
      'database_host'                => "master.vm",
      'puppetdb_host'                => 'master.vm',
      'database_port'                => '5432',
      'database_ssl'                 => true,
      'puppet_master_host'           => 'master.vm',
      'certificate_authority_host'   => 'master.vm',
      'console_port'                 => '443',
      'puppetdb_database_name'       => 'pe-puppetdb',
      'puppetdb_database_user'       => 'pe-puppetdb',
      'pcp_broker_host'              => 'master.vm',
      'puppetdb_port'                => '8081',
      'console_host'                 => 'master.vm'
    },
  },
  environment => 'production',
  require     => Exec['update classifier'],
}

node_group { 'PE Master':
  classes                                              => {
    'pe_repo'                                          => {},
    'pe_repo::platform::el_7_x86_64'                   => {},
    'pe_repo::platform::el_6_x86_64'                   => {},
    'pe_repo::platform::debian_7_amd64'                => {},
    'pe_repo::platform::debian_8_amd64'                => {},
    'pe_repo::platform::ubuntu_1510_amd64'             => {},
    'pe_repo::platform::windows_x86_64'                => {},
    'puppet_enterprise::profile::master'               => {
      'environmentpath'             => '/vagrant/environments',
      'file_sync_enabled'           => false,
      'code_manager_auto_configure' => false,
    },
    'puppet_enterprise::profile::master::mcollective'  => {},
    'puppet_enterprise::profile::mcollective::peadmin' => {},
  },
  environment          => 'production',
  parent               => 'PE Infrastructure',
  rule                 => [ "or", [ "=", "name", $::fqdn] ],
  require              => Exec['update classifier'],
}

exec { 'update classifier':
  command     => "/bin/curl -X POST -H 'Content-Type: application/json' ${curl_opts} https://localhost:4433/classifier-api/v1/update-classes",
  refreshonly => true,
}

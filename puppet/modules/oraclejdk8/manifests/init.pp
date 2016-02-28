class oraclejdk8 {
  include apt
  
  apt::ppa { 'ppa:webupd8team/java': }
  
  exec { 'accept-oracle-license':
    command   => "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections",
    path      => '/usr/bin:/usr/sbin:/bin:/sbin',
    require   => Apt::Ppa['ppa:webupd8team/java'],
  }
  
  package { 'oracle-java8-installer':
    ensure  => 'present',
    require => [ Exec['accept-oracle-license'], Class['apt::update'] ],
  }
}

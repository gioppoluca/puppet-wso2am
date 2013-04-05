package { 'unzip': ensure => present, }

  package { 'mysql': ensure => present, }

  # REQUIREMENTS
  # Java

  class { 'wso2am':
    download_site => "http://something/",
    db_type=>"mysql",
    require       => [ Package['unzip'], Package['mysql']]
  }
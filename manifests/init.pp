# Class: wso2am
#
# This module manages wso2am (Api Manager)
#
# Parameters: 
#    [*db_type*]  - The type of the DB where to store the AM data (as for now just MySQL is supported
#    [*db_host*]  - The host of the MySQL DB
#    [*db_name*]  - The name of the schema for AM (it will be created)
#    [*db_user*]  - The user of the DB
#    [*db_password*]  - The password
#    [*db_tag*]  - The tag used to create the external resource to allow the remote MySQL puppet controlled machine to create the DB 
#    [*product_name*]  - This is here for possible evolution of the module, do not use right now
#    [*version*]  - Version of the product to install only 1.3.0 and 1.3.0 are supported
#    [*download_site*]  - The download site where to get the ZIP (you are advised to provide your HTTP site)
#    [*admin_password*]  - The admin password for the API manager
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class wso2am (
  $db_type= $wso2am::params::db_type,
  $db_host        = $wso2am::params::db_host,
  $db_name        = $wso2am::params::db_name,
  $db_user        = $wso2am::params::db_user,
  $db_password    = $wso2am::params::db_password,
  $db_tag = $wso2am::params::db_tag,
  $product_name   = $wso2am::params::product_name,
  $version        = $wso2am::params::version,
  $download_site  = $wso2am::params::download_site,
  $admin_password = $wso2am::params::admin_password,
  ) inherits wso2am::params {
    if !($version in ['1.3.0', '1.3.1']) {
    fail("\"${version}\" is not a supported version value")
  }
  
  $archive = "$product_name-$version.zip"
  $dir_bin = "/opt/${product_name}-${version}/bin/"
  exec { "get-api-$version":
    cwd     => '/opt',
    command => "/usr/bin/wget ${download_site}${archive}",
    creates => "/opt/${archive}",
    require => Class['opendai_java'],
  }

  exec { "unpack-api-$version":
    cwd       => '/opt',
    command   => "/usr/bin/unzip ${archive}",
    creates   => "/opt/${product_name}-$version",
    subscribe => Exec["get-api-$version"],
    require   => Package['unzip'],
  }



case $db_type {
    undef: {
      # Use default H2 database
    }
    h2: {
      # Use default H2 database
    }
    mysql: {
  # we'll need a DB and a user for the local and config stuff
  @@mysql::db { $db_name:
    user     => $db_user,
    password => $db_password,
    host     => $::fqdn,
    grant    => ['all'],
    tag      => $db_tag,
  }

  file { "/opt/${product_name}-$version/repository/components/lib/mysql-connector-java-5.1.22-bin.jar":
    source  => "puppet:///modules/wso2am/mysql-connector-java-5.1.22-bin.jar",
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }
  file { "/opt/${product_name}-$version/repository/conf/datasources/master-datasources.xml":
    content => template("wso2am/${version}/master-datasources.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }
  }
    default: {
      fail('currently only mysql is supported - please raise a bug on github')
    }
  }

  

  file { "/opt/${product_name}-$version/repository/conf/registry.xml":
    content => template("wso2am/${version}/registry.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }

  file { "/opt/${product_name}-$version/repository/conf/user-mgt.xml":
    content => template("wso2am/${version}/user-mgt.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }

  file { "/opt/${product_name}-$version/bin/wso2server.sh":
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    require => Exec["unpack-api-$version"],
  }

# Need to check that the DB is Available before executing
# also since wso2carbon.log is created at first run and we want to execute just once we check the existence of that file to be sure to exec just at first time
  exec { "setup-wso2am":
    cwd       => "/opt/${product_name}-${version}/bin/",
    path => "/opt/${product_name}-${version}/bin/:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
    environment => ["JAVA_HOME=/usr/java/default",],
    command   => "wso2server.sh -Dsetup",
    creates   => "/opt/${product_name}-$version/repository/logs/wso2carbon.log",
    unless => "/usr/bin/test -s /opt/${product_name}-$version/repository/logs/wso2carbon.log",
    logoutput => true,
    onlyif => "/usr/bin/mysql -h ${db_host} -u ${db_user} -p${db_password} -e\"show databases\"|grep -q ${db_name}",
    require   => [
      File["/opt/${product_name}-$version/bin/wso2server.sh"],
      File["/opt/${product_name}-$version/repository/conf/user-mgt.xml"],
      File["/opt/${product_name}-$version/repository/conf/registry.xml"],
      ],
  }
/*    require   => [
#      File["/opt/wso2api-$version/repository/conf/user-mgt.xml"],
#      File["/opt/wso2api-$version/repository/conf/registry.xml"],
      File["/opt/wso2api-$version/bin/wso2server.sh"],
#      File["/opt/wso2api-$version/repository/conf/datasources/master-datasources.xml"]],
 */  
  file{"/etc/init.d/${product_name}":
    ensure => link,
    owner   => 'root',
    group   => 'root',
    target => "/opt/${product_name}-$version/bin/wso2server.sh",
    
  }


}

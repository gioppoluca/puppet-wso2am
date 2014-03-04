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
  $db_port        = $wso2am::params::db_port,
  $db_name        = $wso2am::params::db_name,
  $db_user        = $wso2am::params::db_user,
  $db_password    = $wso2am::params::db_password,
  $db_tag = $wso2am::params::db_tag,
  $product_name   = $wso2am::params::product_name,
  $version        = $wso2am::params::version,
  $download_site  = $wso2am::params::download_site,
  $admin_password = $wso2am::params::admin_password,
  $external_greg   = $wso2am::params::external_greg,
  $greg_server_url   = $wso2am::params::greg_server_url,
  $greg_db_host   = $wso2am::params::greg_db_host,
  $greg_db_port   = $wso2am::params::greg_db_port,
  $greg_db_name        = $wso2am::params::greg_db_name,
  $greg_db_type   = $wso2am::params::greg_db_type,
  $greg_username   = $wso2am::params::greg_username,
  $greg_password   = $wso2am::params::greg_password,
  $external_bam   = $wso2am::params::external_bam,
  $bam_thrift_port   = $wso2am::params::bam_thrift_port,
  $bam_server_url   = $wso2am::params::bam_server_url,
  $bam_db_host   = $wso2am::params::bam_db_host,
  $bam_db_port   = $wso2am::params::bam_db_port,
  $bam_db_name        = $wso2am::params::bam_db_name,
  $bam_db_type   = $wso2am::params::bam_db_type,
  $bam_username   = $wso2am::params::bam_username,
  $bam_db_password   = $wso2am::params::bam_db_password,
  $bam_admin_password   = $wso2am::params::bam_admin_password,
  $behind_proxy=$wso2am::params::behind_proxy,
  $proxy_port=$wso2am::params::proxy_port,
  $proxy_name=$wso2am::params::proxy_name,
  $proxy_ssl_port=$wso2am::params::proxy_ssl_port,
  $proxy_gateway_path=$wso2am::params::proxy_gateway_path,
  ) inherits wso2am::params {
    if !($version in ['1.3.0', '1.3.1','1.4.0','1.5.0','1.6.0']) {
    fail("\"${version}\" is not a supported version value")
  }
  
  $archive = "${product_name}-${version}.zip"
  $dir_bin = "/opt/${product_name}-${version}/bin/"
  exec { "get-api-$version":
    cwd     => '/opt',
    command => "/usr/bin/wget ${download_site}${archive}",
    creates => "/opt/${archive}",
  }

  exec { "unpack-api-$version":
    cwd       => '/opt',
    command   => "/usr/bin/unzip ${archive}",
    creates   => "/opt/${product_name}-$version",
    subscribe => Exec["get-api-$version"],
    require   => Package['unzip'],
  }

if ($db_type=='mysql') or ($greg_db_type=='mysql') or ($bam_db_type=='mysql'){
  file { "/opt/${product_name}-$version/repository/components/lib/mysql-connector-java-5.1.22-bin.jar":
    source  => "puppet:///modules/wso2am/mysql-connector-java-5.1.22-bin.jar",
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
    before => File["/opt/${product_name}-$version/bin/wso2server.sh"],
  }
  
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

  }
    default: {
      fail('currently only mysql is supported - please raise a bug on github')
    }
  }

if $external_greg == "true" {
case $greg_db_type {
    undef: {
      # Use default H2 database
    }
    h2: {
      # Use default H2 database
    }
    mysql: {
  # we'll need a user access to Db from the API machine
  @@database_user{ "$greg_username@$::fqdn":
  ensure        => present,
  password_hash => mysql_password($greg_password),
  require       => Class['mysql::server'],
  tag      => $db_tag,
  
}
  @@database_grant { "${greg_username}@${fqdn}/${greg_db_name}":
      privileges => "all",
      tag =>$db_tag,
    }
  
  }
    default: {
      fail('currently only mysql is supported - please raise a bug on github')
    }
  }
}
if $external_bam == "true" {
case $bam_db_type {
    undef: {
      # Use default H2 database
    }
    h2: {
      # Use default H2 database
    }
    mysql: {
  # we'll need a user access to Db from the API machine
  @@database_user{ "${bam_username}@$::fqdn":
  ensure        => present,
  password_hash => mysql_password($bam_db_password),
  require       => Class['mysql::server'],
  tag      => $db_tag,
  
}
  @@database_grant { "${bam_username}@${fqdn}/${bam_db_name}":
      privileges => "all",
      tag =>$db_tag,
    }
  
  }
    default: {
      fail('currently only mysql is supported - please raise a bug on github')
    }
  }
}

  file { "/opt/${product_name}-$version/repository/conf/datasources/master-datasources.xml":
    content => template("wso2am/${version}/master-datasources.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
    before => File["/opt/${product_name}-$version/bin/wso2server.sh"],
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
  
  file { "/opt/${product_name}-$version/repository/conf/api-manager.xml":
    content => template("wso2am/${version}/api-manager.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }

  file { "/opt/${product_name}-$version/repository/conf/tomcat/catalina-server.xml":
    content => template("wso2am/${version}/catalina-server.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }

  file { "/opt/${product_name}-$version/repository/conf/axis2/axis2.xml":
    content => template("wso2am/${version}/axis2.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }

  file { "/opt/${product_name}-$version/bin/wso2server.sh":
    content => template("wso2am/${version}/wso2server.sh.erb"),
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

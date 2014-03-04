# === Class: wso2am::params
#
#  The wso2am configuration settings idiosyncratic to different operating
#  systems.
#
# === Parameters
#
# None
#
# === Examples
#
# None
#
# === Authors
#
# Luca Gioppo <gioppoluca@libero.it>
#
# === Copyright
#
# Copyright 2012 Luca Gioppo
#
class wso2am::params {
  $db_type = "h2"
  $db_host = "wso2mysql.$::domain"
  $db_port = 3306
  $db_name = 'odaiam'
  $db_user = 'odaiam'
  $db_password = 'odaiam1'
  $db_tag = 'apiman_db'
  $port_offset = 0
  $version = '1.3.0'
  $download_site = "http://dist2.wso2.org/products/api-manager/"
  $product_name = 'wso2am'
  $admin_password = 'odaiadmin1'
  $external_greg = 'false'
  $greg_server_url = "localhost"
  $greg_db_host = "localhost"
  $greg_db_port = 3306
  $greg_db_name = 'gregdb'
  $greg_db_type = "h2"
  $greg_username = "admin"
  $greg_password = "admin"
  $external_bam = "false"
  $bam_thrift_port = 7612
  $bam_server_url = "localhost"
  $bam_db_host = "localhost"
  $bam_db_port = 3306
  $bam_db_name = 'bamdb'
  $bam_db_type = "h2"
  $bam_username = "admin"
  $bam_db_password = "admin"
  $bam_admin_password = "admin"
$behind_proxy = "false"
  $proxy_port = 80
  $proxy_name = "proxy"
  $proxy_ssl_port=443
  $proxy_gateway_path=''
}

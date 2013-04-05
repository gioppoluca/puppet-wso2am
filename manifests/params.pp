# === Class: moodle::params
#
#  The moodle configuration settings idiosyncratic to different operating
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
# Lucsa Gioppo <gioppoluca@libero.it>
#
# === Copyright
#
# Copyright 2012 Luca Gioppo
#
class wso2am::params {
$db_type            = "h2"
  $db_host            = "wso2mysql.$::domain"
  $db_name            = 'odaiam'
  $db_user            = 'odaiam'
  $db_password        = 'odaiam1'
  $db_tag        = 'apiman_db'
  $port_offset        = 0
  $version = '1.3.0'
  $download_site      = "http://dist2.wso2.org/products/api-manager/"
  $product_name       = 'wso2am'
  $admin_password       = 'odaiadmin1'
  
}

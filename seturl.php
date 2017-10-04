<?php
$httphost = ($_SERVER['VIRTUAL_HOST']);
mysql_connect('mariadb',$_SERVER['DB_ENV_USER'], $_SERVER['DB_ENV_PASS']) or die ('mysql error');
mysql_select_db('magento');
mysql_query('update core_config_data set value="http://'.$httphost.'/" where path = "web/unsecure/base_url"');
mysql_query('update core_config_data set value="http://'.$httphost.'/" where path = "web/secure/base_url"');

echo "host set to: ";
echo $httphost;
echo "\r\n";

system("rm -Rf /var/www/var/cache/mage*");

#!/usr/bin/env bash

chmod +x /opt/bin/*

echo "runing mariadb"
/bin/bash /opt/bin/mariadb_entry.sh mysqld&  #--character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci& #--user=root&


while ! ss -ntlp | grep -q '3306'; do
 ss -ntlp
 echo "waiting for mariab"
 sleep 10;
done


echo "mariaserver running"
echo "running wordpress entry"

source /etc/apache2/envvars
/bin/bash /opt/bin/wordpress_entry.sh apache2&

exec "$@"
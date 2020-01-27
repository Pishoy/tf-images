#! /bin/bash

set -ex

chmod 400 -R /etc/ssh/
mkdir -p /run/sshd
[ -d /root/.ssh/ ] || mkdir /root/.ssh
/etc/init.d/ssh start
chown -R postgres.postgres /var/lib/postgresql/
[[ -d /var/log/postgresql ]] || mkdir /var/log/postgresql
chown -R postgres.postgres /var/log/postgresql
gpasswd -a postgres ssl-cert
chown root:ssl-cert  /etc/ssl/private/ssl-cert-snakeoil.key
chmod 640 /etc/ssl/private/ssl-cert-snakeoil.key
chown postgres:ssl-cert /etc/ssl/private
chown -R postgres /var/run/postgresql
chown -R postgres.postgres /etc/postgresql
find /var/lib/postgresql -maxdepth 0 -empty -exec sh -c 'pg_dropcluster 10 main && pg_createcluster 10 main' \;
echo 'remove a record was added by zos that make our server slow, below is resolv.conf file contents'
cat /etc/resolv.conf
sed -i '/^nameserver 10./d' /etc/resolv.conf
locale-gen en_US.UTF-8
/etc/init.d/postgresql start
bash /.prepare_database.sh
bash /.start_discourse.sh
echo checking postgres and redis are running and export
ps aux
env
/etc/service/unicorn/run &
nginx -t
/etc/init.d/nginx start
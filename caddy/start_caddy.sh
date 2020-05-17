#!/bin/bash
set -ex
# prepare ssh
[ -d /etc/ssh/ ] && chmod 400 -R /etc/ssh/
mkdir -p /run/sshd
[ -d /root/.ssh/ ] || mkdir /root/.ssh

touch /mnt/Caddyfile

mkdir /var/log/{caddy,ssh}/ -p
supervisord -c /etc/supervisor/supervisord.conf
exec "$@"

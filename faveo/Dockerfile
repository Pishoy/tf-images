FROM wyveo/nginx-php-fpm:php71


# Install necessary packages

RUN apt-get update -y && apt-get install -y php7.1-imap cron ca-certificates && rm -rf /var/lib/apt/lists/*

# Force PHP to log to nginx
RUN echo "catch_workers_output = yes" >> /etc/php/7.1/fpm/php-fpm.conf

# Enable php by default
COPY root/opt/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /usr/share/nginx/

RUN rm -rf *

# Clone the project from git
RUN git clone https://github.com/ladybirdweb/faveo-helpdesk.git .

RUN composer install


# Add to crontab file

RUN echo '* * * * * php /usr/share/nginx/artisan schedule:run > /dev/null 2>&1' >>/etc/cron.d/faveo-cron
RUN chmod 0644 /etc/cron.d/faveo-cron
RUN crontab /etc/cron.d/faveo-cron
RUN sed -i 's/user  nginx/user  www-data/g' /etc/nginx/nginx.conf
RUN sed -i "s/max_execution_time = .*/max_execution_time = 120/" /etc/php/7.1/fpm/php.ini
RUN php -m
RUN sed -i "s/listen.owner = nginx/listen.owner = www-data/g;s/listen.group = nginx/listen.group = www-data/g" /etc/php/7.1/fpm/pool.d/www.conf
RUN sed -i "s|;listen.mode = 0660|listen.mode = 0660|g" /etc/php/7.1/fpm/pool.d/www.conf

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

# https://bugs.debian.org/830696 (apt uses gpgv by default in newer releases, rather than gpg)
RUN set -ex; \
        apt-get update; \
        if ! which gpg; then \
        apt-get install -y --no-install-recommends gnupg; \
        fi; \
        if ! gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
        # Ubuntu includes "gnupg" (not "gnupg2", but still 2.x), but not dirmngr, and gnupg 2.x requires dirmngr
        # so, if we're not running gnupg 1.x, explicitly install dirmngr too
        apt-get install -y --no-install-recommends dirmngr; \
        fi; \
        rm -rf /var/lib/apt/lists/*

# add gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -ex; \
        \
        fetchDeps=' \
        ca-certificates \
        wget \
        '; \
        apt-get update; \
        apt-get install -y --no-install-recommends $fetchDeps; \
        rm -rf /var/lib/apt/lists/*; \
        \
        dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
        wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
        wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
        \
        # verify the signature
        export GNUPGHOME="$(mktemp -d)"; \
        gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
        gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
        command -v gpgconf > /dev/null && gpgconf --kill all || :; \
        rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
        \
        chmod +x /usr/local/bin/gosu; \
        # verify that the binary works
        gosu nobody true; \
        \
        apt-get purge -y --auto-remove $fetchDeps

RUN mkdir /docker-entrypoint-initdb.d

# install "pwgen" for randomizing passwords
# install "tzdata" for /usr/share/zoneinfo/
RUN set -ex; \
        rm /etc/apt/sources.list.d/php.list; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
        pwgen \
        tzdata \
        ; \
        rm -rf /var/lib/apt/lists/*

ENV GPG_KEYS \
        # pub   rsa4096 2016-03-30 [SC]
        #         177F 4010 FE56 CA33 3630  0305 F165 6F24 C74C D1D8
        # uid           [ unknown] MariaDB Signing Key <signing-key@mariadb.org>
        # sub   rsa4096 2016-03-30 [E]
        177F4010FE56CA3336300305F1656F24C74CD1D8
RUN set -ex; \
        export GNUPGHOME="$(mktemp -d)"; \
        for key in $GPG_KEYS; do \
        gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
        done; \
        gpg --batch --export $GPG_KEYS > /etc/apt/trusted.gpg.d/mariadb.gpg; \
        command -v gpgconf > /dev/null && gpgconf --kill all || :; \
        rm -r "$GNUPGHOME"; \
        apt-key list

# bashbrew-architectures: amd64 arm64v8 ppc64le
ENV MARIADB_MAJOR 10.4
#ENV MARIADB_VERSION 1:10.4.8+maria~bionic
# release-status:Stable
# (https://downloads.mariadb.org/mariadb/+releases/)

RUN set -e;\
        echo "deb http://ftp.osuosl.org/pub/mariadb/repo/$MARIADB_MAJOR/ubuntu bionic main" > /etc/apt/sources.list.d/mariadb.list; \
        { \
        echo 'Package: *'; \
        echo 'Pin: release o=MariaDB'; \
        echo 'Pin-Priority: 999'; \
        } > /etc/apt/preferences.d/mariadb
# add repository pinning to make sure dependencies from this MariaDB repo are preferred over Debian dependencies
#  libmariadbclient18 : Depends: libmysqlclient18 (= 5.5.42+maria-1~wheezy) but 5.5.43-0+deb7u1 is to be installed

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN set -ex; \
        { \
        echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password password 'unused'; \
        echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password_again password 'unused'; \
        } | debconf-set-selections; \
        apt-get update; \
        apt-get install -y \
        mariadb-server \
        # mariadb-backup is installed at the same time so that `mysql-common` is only installed once from just mariadb repos
        mariadb-backup \
        socat \
        ; \
        rm -rf /var/lib/apt/lists/*; \
        # comment out any "user" entires in the MySQL config ("docker-entrypoint.sh" or "--user" will handle user switching)
        sed -ri 's/^user\s/#&/' /etc/mysql/my.cnf /etc/mysql/conf.d/*; \
        # purge and re-create /var/lib/mysql with appropriate ownership
        rm -rf /var/lib/mysql; \
        mkdir -p /var/lib/mysql /var/run/mysqld; \
        chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
        # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
        chmod 777 /var/run/mysqld; \
        # prepare data dir
        mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql ;\
        # comment out a few problematic configuration values
        find /etc/mysql/ -name '*.cnf' -print0 \
        | xargs -0 grep -lZE '^(bind-address|log)' \
        | xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/'; \
        # don't reverse lookup hostnames, they are usually another container
        echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

VOLUME /var/lib/mysql

EXPOSE 3306

# install supervisor
RUN apt-get update -y
RUN apt-get install python3-pip openssh-server vim -y

RUN pip3 install supervisor

COPY supervisor.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisor/php-fpm
RUN mkdir -p /var/log/supervisor/nginx
RUN mkdir -p /var/log/supervisor/cron/
RUN mkdir -p /var/run/mysqld

COPY root/opt/bin /opt/bin

RUN chmod +x /opt/bin/*

# To do: initialize the database so it can run properly

ENTRYPOINT ["/opt/bin/run_all.sh" ]

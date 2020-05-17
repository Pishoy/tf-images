FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update ; \
    apt-get install -y  curl; \
    apt-get install -y python3 python3-pip ; \
    apt-get install -y openssh-server vim net-tools

# install supervisor
RUN pip3 install supervisor

# instal caddy

RUN curl https://getcaddy.com | bash -s personal

# install caddy

COPY supervisor.conf /etc/supervisor/supervisord.conf
COPY start_caddy.sh /start_caddy.sh

RUN chmod  +x  /start_caddy.sh
ENTRYPOINT ["/start_caddy.sh" ]

# to support zosv1 , can removed later
COPY startup.toml /.startup.toml
RUN chmod  +x  /.startup.toml


FROM  bishoyabdo/tf_discourse:latest
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install net-tools -y
COPY startup.sh /discourse_startup.sh
COPY prepare_database.sh /.prepare_database.sh
COPY start_discourse.sh /.start_discourse.sh
RUN chmod +x /discourse_startup.sh
ENTRYPOINT ["/discourse_startup.sh"]
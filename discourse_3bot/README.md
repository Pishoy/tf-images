# Building

in the discourse directory

```
    docker build -t threefolddev/forum:latest . 
    docker push threefolddev/forum:latest
```
- then convert it form our hub to an flist https://hub.grid.tf
- note we use a prepared image in Dockerfile called threefolddev/tf-discourse
- tf-discourse image has some prepared configuration and scripts, this image created by below reference 
- tf-discourse image prepared configuration and scripts are taken from following templates 
   https://github.com/discourse/discourse_docker/tree/master/templates

## References

https://github.com/discourse/discourse_docker/tree/master/image/base

### create docker container 
```
docker run -it --name myforum -p '2222:22'  '803:80' \ 
-envs DISCOURSE_SMTP_PASSWORD=ursmtppassword --name forum-test
-envs DISCOURSE_VERSION=staging -envs RAILS_ENV=production -envs DISCOURSE_HOSTNAME=forum11.threefold.io \ 
-envs DISCOURSE_SMTP_USER_NAME=apikey -envs DISCOURSE_SMTP_ADDRESS=smtp.sendgrid.net -envs DISCOURSE_DEVELOPER_EMAILS=bishoy@incubaid.com -envs DISCOURSE_SMTP_PORT=587 \ 
-envs THREEBOT_PRIVATE_KEY="yourkey" -envs FLASK_SECRET_KEY="yoursceret" \
-envs THREEBOT_URL=https://login.staging.jimber.org -envs OPEN_KYC_URL=https://openkyc.staging.jimber.org/verification/verify-sei
```

### additional env variables have a defaults if not set as below
    
     RUBY_GC_HEAP_GROWTH_MAX_SLOTS=40000
     RUBY_GC_HEAP_INIT_SLOTS=400000
     RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=1.5
     RUBY_GLOBAL_METHOD_CACHE_SIZE=131072
     PG_MAJOR=10
     UNICORN_SIDEKIQS=1
     DISCOURSE_DB_SOCKET=/var/run/postgresql
     home=/var/www/discourse
     upload_size=10m
     UNICORN_WORKERS=4
     DISCOURSE_SMTP_ENABLE_START_TLS=true
     
    
- logs are located in /var/log and app logs are in /var/www/discourse/log/
- after setup the discourse using admin account, ask another account to login with 3bot and grant him as an admin
- the local data in /var/lib/postgresql , redis in /shared/redis_data ,application /var/www/discourse/public which has upload and backup
- from admin discourse, you can set a periodic backup to be taken in path /var/www/discourse/public/backups/default

### configuration for https
    we are using self-sgined by nginx
    
### Reference

https://github.com/discourse/discourse_docker

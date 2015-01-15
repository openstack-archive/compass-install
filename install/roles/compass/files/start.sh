#!/bin/bash

# activate virtualenv
source `which virtualenvwrapper.sh`
workon compass-core

# start mysqld service, push it to bg
/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "waiting for mariadb to startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

echo "mariadb started"

# set mysql with default username and password
mysqladmin -h127.0.0.1 --port=3306 -u root password root

# create db 'compass'
mysql -h127.0.0.1 --port=3306 -uroot -proot -e "create database compass"

# start compass services
/opt/compass/bin/manage_db.py createdb
/usr/sbin/apachectl -k start
/usr/sbin/rabbitmq-server &
/usr/bin/redis-server &
/usr/sbin/ntpd &
ln -s /root/.virtualenvs/compass-core/bin/celery /opt/compass/bin/celery
CELERY_CONFIG_MODULE=compass.utils.celeryconfig_wrapper C_FORCE_ROOT=1 /opt/compass/bin/celery worker &> /tmp/celery-worker.log &
/opt/compass/bin/progress_update.py &> /tmp/progress_update.log &
touch /var/log/compass/celery.log
tail -f /var/log/compass/celery.log

#/bin/bash
set -e
/opt/compass/bin/manage_db.py createdb
# /opt/compass/bin/clean_installers.py
# /opt/compass/bin/clean_installation_logs.py
/usr/sbin/apachectl -D NO_DETACH -D FOREGROUND
/usr/bin/redis-server &
CELERY_CONFIG_MODULE=compass.utils.celeryconfig_wrapper C_FORCE_ROOT=1 /opt/compass/bin/celery worker &> /tmp/celery-worker.log &
/opt/compass/bin/progress_update.py &> /tmp/progress_update.log

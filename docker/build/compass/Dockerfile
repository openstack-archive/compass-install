FROM centos:centos7

ADD conf/setup.conf /root/setup.conf
RUN chmod +x /root/setup.conf
## install yum repos and then packages
RUN source /root/setup.conf && \
    rpm -Uvh $EPEL7 >& /dev/null && \
    sed -i 's/^mirrorlist=https/mirrorlist=http/g' /etc/yum.repos.d/epel.repo && \
    rpm -Uvh $ATOMIC >& /dev/null && \
    sed -i 's/^mirrorlist=https/mirrorlist=http/g' /etc/yum.repos.d/atomic.repo
RUN yum clean all >& /dev/null && \
    yum update -y --skip-broken >&/dev/null && \
    yum install -y rsyslog logrotate ntp iproute openssh-clients python python-devel git wget rabbitmq-server mod_wsgi httpd squid yum-utils gcc net-snmp-utils net-snmp net-snmp-python openssl openssl098e ca-certificates redis mariadb mariadb-server mariadb-devel python-virtualenv python-setuptools MySQL-python

# set up pip and install python virtual environment
RUN easy_install --upgrade pip
RUN pip install virtualenvwrapper

# get compass-core code
WORKDIR /root
RUN source /root/setup.conf && \
    git clone $COMPASS_CORE
WORKDIR /root/compass-core
RUN mkdir /root/backup

# update rsyslog conf
RUN cp -rn /etc/rsyslog.conf /root/backup
RUN rm -rf /etc/rsyslog.conf
RUN cp -rf misc/rsyslog/rsyslog.conf /etc/rsyslog.conf
RUN chmod 644 /etc/rsyslog.conf

# update logrotate.d
RUN cp -rn /etc/logrotate.d /root/backup
RUN rm -rf /etc/logrotate.d/*
RUN cp -rf misc/logrotate.d/* /etc/logrotate.d/
RUN chmod 644 /etc/logrotate.d/*

# grant permission to httpd and mysqld log dirs
RUN mkdir /var/log/mysql
RUN chmod 777 /var/log/httpd
RUN chmod 777 /var/log/mysql

# clone compass web
WORKDIR /root
RUN source /root/setup.conf && \
    git clone $COMPASS_WEB

# setup python requirements
# remove 'mysql-python' from requirements as centos 7 supports the yum package
WORKDIR /root/compass-core
RUN sed -i 's/MySQL-python/#MySQL-python/g' requirements.txt
RUN source `which virtualenvwrapper.sh` && \
    mkvirtualenv --system-site-packages compass-core && \
    workon compass-core && \
    pip install -U -r requirements.txt

# download local repo
WORKDIR /tmp
RUN source /root/setup.conf && \
    wget $LOCAL_REPO

# snmp
# instead of moving mibs to /usr/local/share/snmp/mibs, centos7 puts mibs file at /usr/share/snmp/mibs/

WORKDIR /root/compass-core
RUN yes|cp -rf mibs/* /usr/share/snmp/mibs/
RUN cp -rf misc/snmp/snmp.conf /etc/snmp/snmp.conf
RUN chmod 644 /etc/snmp/snmp.conf
RUN mkdir -p /var/lib/net-snmp/mib_indexes
RUN chmod 755 /var/lib/net-snmp/mib_indexes

# install compass-core
WORKDIR /root/compass-core
RUN mkdir -p /etc/compass
RUN mkdir -p /opt/compass/bin
RUN mkdir -p /var/log/compass
RUN mkdir -p /var/log/chef
RUN mkdir -p /var/www/compass

RUN cp -rf misc/apache/ods-server.conf /etc/httpd/conf.d/ods-server.conf
RUN cp -rf conf/* /etc/compass/
RUN cp -rf bin/*.py /opt/compass/bin/
RUN cp -rf bin/*.sh /opt/compass/bin/
RUN cp -rf bin/compassd /usr/bin/
RUN cp -rf bin/switch_virtualenv.py.template /opt/compass/bin/switch_virtualenv.py
RUN ln -s -f /opt/compass/bin/compass_check.py /usr/bin/compass
RUN ln -s -f /opt/compass/bin/compass_wsgi.py /var/www/compass/compass.wsgi
RUN cp -rf bin/chef/* /opt/compass/bin/
RUN cp -rf bin/cobbler/* /opt/compass/bin/
RUN cp -rf /usr/lib64/libcrypto.so.10 /usr/lib64/libcrypto.so

# setup compass-core and related confs
RUN mkdir -p /opt/compass/db && \
    chmod -R 777 /opt/compass/db
RUN chmod -R 777 /var/log/compass
RUN chmod -R 777 /var/log/chef
RUN echo "export C_FORCE_ROOT=1" > /etc/profile.d/celery_env.sh
RUN chmod +x /etc/profile.d/celery_env.sh
WORKDIR /root/compass-core
RUN source `which virtualenvwrapper.sh` && \
    workon compass-core && \
    python setup.py install

# compass web
WORKDIR /root/compass-web
RUN yum -y install tar
RUN mkdir -p /var/www/compass_web
RUN cp -rf v2 /var/www/compass_web/
WORKDIR /tmp
RUN tar -xzvf local_repo.tar.gz
RUN mv -f local_repo/* /var/www/compass_web/v2/

# enable start-up script
ADD scripts/sample_start /root/sample_start
RUN chmod +x /root/sample_start

# start: perform some post-installation tasks
# modify compass refresh to make it work in containers
ADD scripts/refresh.sh /opt/compass/bin/refresh.sh
RUN chmod +x /opt/compass/bin/refresh.sh

# set python home for virtualenv
RUN sed -i "s|\$PythonHome|\/root\/\.virtualenvs\/compass-core|g" /opt/compass/bin/switch_virtualenv.py

# add apache to root group
RUN usermod -a -G `groups root|awk '{print$3}'` apache

# configure mysql
RUN /usr/bin/mysql_install_db && \
    chown -R mysql:mysql /var/lib/mysql

# CMD ["/root/sample_start"]

EXPOSE 80
EXPOSE 22
EXPOSE 123
EXPOSE 3306

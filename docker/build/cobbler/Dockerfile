FROM centos:centos6

ADD conf/setup.conf /tmp/setup.conf
ADD conf/cobbler_web.conf /etc/httpd/conf.d/cobbler_web.conf
ADD conf/ssl.conf /etc/httpd/conf.d/ssl.conf
ADD conf/tftpd.template /etc/cobbler/tftpd.template
ADD conf/modules.conf /etc/cobbler/modules.conf
ADD conf/distributions /tmp/distributions
ADD conf/dhcp.template /etc/cobbler/dhcp.template
RUN chmod +x /tmp/setup.conf

# add epel repo and atomic(for installing reprepro: a command tool to build debian repos) repo
RUN source /tmp/setup.conf && \
    rpm -Uvh $EPEL7 && \
    sed -i 's/^mirrorlist=https/mirrorlist=http/g' /etc/yum.repos.d/epel.repo && \
    rpm -Uvh $ATOMIC && \
    sed -i 's/^mirrorlist=https/mirrorlist=http/g' /etc/yum.repos.d/atomic.repo

RUN yum clean all && \
    yum update -y --skip-broken && \
    yum install -y syslinux bind rsync dhcp xinetd tftp-server gcc httpd cobbler cobbler-web createrepo mkisofs python-cheetah python-simplejson python-urlgrabber PyYAML PyYAML Django cman pykickstart reprepro git wget debmirror cman openssl openssl098e

# configure cobbler web and ssl
RUN mkdir -p /root/backup/cobbler && \
    cp -rn /etc/httpd/conf.d /root/backup/cobbler && \
    chmod 644 /etc/httpd/conf.d/cobbler_web.conf && \
    chmod 644 /etc/httpd/conf.d/ssl.conf

# update tftpd template
RUN chmod 644 /etc/cobbler/tftpd.template

# update modules conf
RUN chmod 644 /etc/cobbler/modules.conf

# setup cobbler default web username password: cobbler/cobbler
RUN (echo -n "cobbler:Cobbler:" && echo -n "cobbler:Cobbler:cobbler" | md5sum - | cut -d' ' -f1) > /etc/cobbler/users.digest


# get adapters code
WORKDIR /root/
RUN git clone -b dev/experimental https://git.openstack.org/stackforge/compass-adapters.git && \
    cp -rn /var/lib/cobbler/snippets /root/backup/cobbler/ && \
    cp -rn /var/lib/cobbler/scripts /root/backup/cobbler && \
    cp -rn /var/lib/cobbler/kickstarts/ /root/backup/cobbler/ && \
    cp -rn /var/lib/cobbler/triggers /root/backup/cobbler/ && \
    rm -rf /var/lib/cobbler/snippets/* && \
    cp -rf compass-adapters/cobbler/snippets/* /var/lib/cobbler/snippets/ && \
    cp -rf compass-adapters/cobbler/scripts/* /var/lib/cobbler/scripts/ && \
    cp -rf compass-adapters/cobbler/triggers/* /var/lib/cobbler/triggers/ && \
    chmod 777 /var/lib/cobbler/snippets && \
    chmod 777 /var/lib/cobbler/scripts && \
    chmod -R 666 /var/lib/cobbler/snippets/* && \
    chmod -R 666 /var/lib/cobbler/scripts/* && \
    chmod -R 755 /var/lib/cobbler/triggers && \
    rm -f /var/lib/cobbler/kickstarts/default.ks && \
    rm -f /var/lib/cobbler/kickstarts/default.seed && \
    cp -rf compass-adapters/cobbler/kickstarts/default.ks /var/lib/cobbler/kickstarts/ && \
    cp -rf compass-adapters//cobbler/kickstarts/default.seed /var/lib/cobbler/kickstarts/ && \
    chmod 666 /var/lib/cobbler/kickstarts/default.ks && \
    chmod 666 /var/lib/cobbler/kickstarts/default.seed && \
    mkdir -p /var/www/cblr_ks && \
    chmod 755 /var/www/cblr_ks && \
    cp -rf compass-adapters/cobbler/conf/cobbler.conf /etc/httpd/conf.d/ && \
    chmod 644 /etc/httpd/conf.d/cobbler.conf && \
    export passwd=$(openssl passwd -1 -salt 'huawei' '123456') && \
    sed -i "s,^default_password_crypted:[ \t]\+\"\(.*\)\",default_password_crypted: \"$cobbler_passwd\",g" /etc/cobbler/settings && \
    chmod 644 /etc/cobbler/settings
    

# disable selinux
RUN echo 0 > /selinux/enforce

# create log dirs
RUN mkdir -p /var/log/cobbler && \
    mkdir -p /var/log/cobbler/tasks && \
    mkdir -p /var/log/cobbler/anamon && \
    chmod -R 777 /var/log/cobbler

# create centos ppa repo dir
RUN rm -rf /var/lib/cobbler/repo_mirror/centos_ppa_repo && \
    mkdir -p /var/lib/cobbler/repo_mirror/centos_ppa_repo

# download centos repo pkgs
WORKDIR /var/lib/cobbler/repo_mirror/centos_ppa_repo
ADD conf/setup.conf /tmp/setup.conf
RUN source /tmp/setup.conf && \
    wget $NTP && \
    wget $SSH_CLIENTS && \
    wget $OPENSSH && \
    wget $IPROUTE && \
    wget $WGET && \
    wget $NTPDATE && \
    wget $YUM_PRIORITIES && \
    wget $JSONC && \
    wget $LIBESTR && \
    wget $LIBGT && \
    wget $LIBLOGGING && \
    wget $RSYSLOG && \
    wget $CHEF_CLIENT_CENTOS

# creating ubuntu repo
RUN rm -rf /var/lib/cobbler/repo_mirror/ubuntu_ppa_repo && \
    mkdir -p /var/lib/cobbler/repo_mirror/ubuntu_ppa_repo/conf && \
    mv /tmp/distributions /var/lib/cobbler/repo_mirror/ubuntu_ppa_repo/conf/distributions && \
    chmod 644 /var/lib/cobbler/repo_mirror/ubuntu_ppa_repo/conf/distributions && \
    wget -O /var/lib/cobbler/repo_mirror/ubuntu_ppa_repo/chef_11.8.0-1.ubuntu.12.04_amd64.deb http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.8.0-1.ubuntu.12.04_amd64.deb

ADD conf/1404_distributions /tmp/1404_distributions

RUN rm -rf /var/lib/cobbler/repo_mirror/ubuntu_14_04_ppa_repo && \
    mkdir -p /var/lib/cobbler/repo_mirror/ubuntu_14_04_ppa_repo/conf && \
    mv /tmp/1404_distributions /var/lib/cobbler/repo_mirror/ubuntu_14_04_ppa_repo/conf/distributions && \
    chmod 644 /var/lib/cobbler/repo_mirror/ubuntu_14_04_ppa_repo/conf/distributions && \
    wget -O /var/lib/cobbler/repo_mirror/ubuntu_14_04_ppa_repo/chef_12.1.1-1_amd64.deb https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/13.04/x86_64/chef_12.1.1-1_amd64.deb
    

# create repos
WORKDIR /var/lib/cobbler/repo_mirror
RUN createrepo centos_ppa_repo && \
    find ubuntu_ppa_repo -name \*.deb -exec reprepro -Vb ubuntu_ppa_repo includedeb ppa {} \; && \
    find ubuntu_14_04_ppa_repo -name \*.deb -exec reprepro -Vb ubuntu_14_04_ppa_repo includedeb ppa {} \;

# add repos to cobbler repo and get loaders
RUN /usr/sbin/apachectl -k start && \
    /usr/bin/cobblerd start \& && \
    cobbler repo add --mirror=/var/lib/cobbler/repo_mirror/centos_ppa_repo --name=centos_ppa_repo --mirror-locally=Y --arch=x86_64 && \
    cobbler repo add --mirror=/var/lib/cobbler/repo_mirror/ubuntu_ppa_repo --name=ubuntu_ppa_repo --mirror-locally=Y --arch=x86_64 && \
    cobbler repo add --mirror=/var/lib/cobbler/repo_mirror/ubuntu_14_04_ppa_repo --name=ubuntu_14_04_ppa_repo --mirror-locally=Y --arch=x86_64 && \
    cobbler reposync && \
    cobbler get-loaders

ADD conf/cobbler.settings /etc/cobbler/settings
RUN sed -i 's/disable\([ \t]\+\)=\([ \t]\+\)yes/disable\1=\2no/g' /etc/xinetd.d/rsync && \
    sed -i 's/^@dists=/# @dists=/g' /etc/debmirror.conf && \
    sed -i 's/^@arches=/# @arches=/g' /etc/debmirror.conf

# create mount points
RUN mkdir -p /var/lib/cobbler/mount_point
VOLUME ["/var/lib/cobbler/mount_point"]
ADD scripts/start /root/start
RUN chmod +x /root/start
CMD ["/root/start"]


EXPOSE 80
EXPOSE 69 69/udp
EXPOSE 53 53/udp
EXPOSE 25151
EXPOSE 443
EXPOSE 873

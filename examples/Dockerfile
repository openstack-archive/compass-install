FROM compassindocker/compass:test

ADD scripts/start /root/start
ADD conf/compass.setting /etc/compass/setting
ADD conf/cobbler.conf /etc/compass/os_installer/cobbler.conf
ADD conf/chef-icehouse.conf /etc/compass/package_installer/chef-icehouse.conf
ADD conf/chef-client.pem /etc/chef-client.pem

RUN chmod +x /root/start

CMD ["/root/start"]
EXPOSE 80
EXPOSE 123

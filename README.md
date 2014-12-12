Compass Install
===============

How to use examples/compass?
---------------------------------------------
1. Make sure you have docker installed.
2. Make sure you have working cobbler and chef servers, where all adapter related code has been updated to the latest.
3. Go to your chef server's web UI and create a client with admin privileges, name it as docker-controller.
4. You will have ONE CHANCE to copy the private key, copy it and paste it to replace `conf/chef-client.pem`
5. Go to `examples/compass/conf` directory
6. Edit chef-icehouse.conf, change '10.145.89.140' to your chef server's IP.
7. Edit cobbler.conf and change the IP to your cobbler server's IP.
8. Edit compass.setting
  - COMPASS\_SUPPORTED\_PROXY: this is not supported in containerized compass, use the default value
  - COMPASS\_SUPPORTED\_DEFAULT_NOPROXY: default value
  - COMPASS\_SUPPORTED\_NTP\_SERVER: I am planning to move ntpd to cobbler container, so for now just point this value to any working compass server.
  - COMPASS\_DNS\_SERVERS: cobbler server takes care of dns, use cobbler server IP
  - COMPASS\_SUPPROTED\_DOMAINS: default
  - COMPASS\_SUPPORTED\_DEFAULT_GATEWAY: default
  - COMPASS\_SUPPORTED\_LOCAL\_REPO: use `http://$your\_host\_for\_docker:8080`
9. Go to `examples/compass` and run `docker build -t {image_name} .`
10. Once build finishes, run `docker run -d -p 8080:80 -i -t {image_name}`
11. celery log will be displayed on terminal, once the start script finishes running, open your web browser and go to `http://$your\_host\_for\_docker:8080`

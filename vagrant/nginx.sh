#!/bin/bash
# run as root
# install, enable, configure and start an nginx webserver

set -exuv

apt install nginx -y
systemctl enable nginx

# remove the default welcome page
rm -f /etc/nginx/sites-enabled/default

# link in the ./html directory on the host
cp /vagrant/nginx/default.conf /etc/nginx/sites-enabled/

# test the config
nginx -t

# start/restart the server
systemctl restart nginx

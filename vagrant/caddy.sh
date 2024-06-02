#!/bin/bash
# run as root
# install, enable, configure and start a Caddy webserver

set -exuv

# install from official repository rather than their PPA (dl.cloudsmith.io at time of writing).
apt install caddy -y
systemctl enable caddy

# remove the default welcome page
rm /etc/caddy/Caddyfile

# link in the ./html directory on the host
cp /vagrant/caddy/Caddyfile /etc/caddy/

caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile

# start/restart the server
systemctl restart caddy

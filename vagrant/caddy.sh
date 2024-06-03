#!/bin/bash
# run as root
# install, enable, configure and start a Caddy webserver

set -e  # everything must pass
set -u  # no unbound variables
set -xv # output the scripts and interpolated steps

# install from official repository rather than their PPA (dl.cloudsmith.io at time of writing).

# in 24.04 we can install Caddy directly:
#apt install caddy -y
#systemctl enable caddy

# but in 22.04 we have to do it this way:
# https://caddyserver.com/docs/install#debian-ubuntu-raspbian

# caddy deps
apt install --assume-yes debian-keyring debian-archive-keyring apt-transport-https curl

# caddy gpg key
if [ ! -e /usr/share/keyrings/caddy-stable-archive-keyring.gpg ]; then
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
fi

# caddy apt pkg source
if [ ! -e /etc/apt/sources.list.d/caddy-stable.list ]; then
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' > /etc/apt/sources.list.d/caddy-stable.list
fi

# refresh pkgs
apt update
apt install caddy --assume-yes

# remove the default welcome page
rm /etc/caddy/Caddyfile

# link in the ./html directory on the host
cp /vagrant/caddy/Caddyfile /etc/caddy/

caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile

# start/restart the server
systemctl restart caddy

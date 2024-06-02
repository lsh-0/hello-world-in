#!/bin/bash
# run as root
# install, enable, configure and start a Python webserver

set -e  # everything must pass
set -u  # no unbound variables
set -xv # output the scripts and interpolated steps

apt install python3 -y

# we'll run the service as 'www-data', however this user may not exist.
if ! id www-data; then
    useradd --system --shell /usr/sbin/nologin www-data
fi

# systemd service file
cp /vagrant/python/python-webserver.service /lib/systemd/system/

# reload in case of any changes
systemctl daemon-reload

systemctl enable python-webserver
systemctl start python-webserver

#!/bin/bash
# run as root
# install, enable, configure and start a Go webserver

set -e  # everything must pass
set -u  # no unbound variables
set -xv # output the scripts and interpolated steps

apt install golang -y --no-install-recommends

# we'll run the service as 'www-data', however this user may not exist.
if ! id www-data; then
    useradd --system --shell /usr/sbin/nologin www-data
    chown -R www-data:www-data /var/www
fi

# systemd service file
cp /vagrant/go/go-webserver.service /lib/systemd/system/

# reload in case of any changes
systemctl daemon-reload

systemctl enable go-webserver
systemctl start go-webserver

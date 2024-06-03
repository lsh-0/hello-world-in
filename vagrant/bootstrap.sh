#!/bin/bash
# run as root
# common commands to execute on every 'vagrant provision'

set -e  # everything must pass
set -u  # no unbound variables
set -xv # output the scripts and interpolated steps

# no ncurses prompts from apt
export DEBIAN_FRONTEND=noninteractive

# refresh installed packages
apt update --assume-yes --quiet

function stop_service() {
    app_name="$1"
    if systemctl is-active --quiet "$app_name"; then
        systemctl stop "$app_name"
        systemctl disable "$app_name"
    fi
}

# stop and disable any services that may have been enabled on a previous `vagrant provision`
stop_service salt-minion
stop_service caddy
stop_service nginx
stop_service python-webserver
stop_service go-webserver

# success
exit 0

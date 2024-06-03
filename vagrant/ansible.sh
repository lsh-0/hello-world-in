#!/bin/bash
# run as root
# install and configure Ansible host and guest dependencies.
# Ansible will be used to configure 'localhost' rather than a remote host.

set -e  # everything must pass
set -u  # no unbound variables
set -xv # output the scripts and interpolated steps

apt install python3 ansible --no-install-recommends --assume-yes

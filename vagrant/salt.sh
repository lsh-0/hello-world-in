#!/bin/bash
# run as root
# install and configure SaltStack as a masterless minion

set -e  # everything must pass
set -u  # no unbound variables
set -xv # output the scripts and interpolated steps

installing=false
if ! command -v salt-call; then
    installing=true
fi

# salt-minion
if $installing; then
    wget https://bootstrap.saltstack.com --output-document salt_bootstrap.sh --no-verbose
    sh salt_bootstrap.sh stable 3006.8

    # install salt dependencies
    # some Salt states require extra libraries to be installed before calling highstate.
    # salt builtins: https://github.com/saltstack/salt/blob/master/requirements/static/pkg/py3.9/linux.txt
    salt-pip install "docker~=7.1"
else
    echo "Skipping minion bootstrap, found: $(salt-minion --version)"
fi

# configure the (masterless) salt-minion
cp /vagrant/salt/minion /etc/salt/

systemctl restart salt-minion

exit 0

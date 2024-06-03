#!/bin/bash
# run as current user
# install and configure Ansible guest dependencies

set -e  # everything must pass
set -u  # no unbound variables
set -xv # output the scripts and interpolated steps

ansible-playbook --inventory /vagrant/ansible/hosts /vagrant/ansible/nginx.yml

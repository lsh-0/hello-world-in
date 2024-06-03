#!/bin/bash
# run as root
# run highstate as a Caddy loving minion.
set -e

salt-call state.highstate --id=caddy-minion

#!/bin/bash
# run as root
# run highstate as a nginx loving minion.
set -e

salt-call state.highstate --id=nginx-minion

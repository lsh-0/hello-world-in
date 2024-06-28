#!/bin/bash
# run as a regular user.
# assumes regular user can run `docker` commands.
set -uexv

app="$1"

docker build --file "Dockerfile.$app" --rm --tag "hello-world/$app" .

#!/bin/bash
set -euxv

app="$1"

docker build --file "Dockerfile.$app" --rm --tag "hello-world/$app" .

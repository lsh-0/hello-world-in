#!/bin/bash
set -euxv

app="$1"

docker build --file "Docker.$app" --rm --tag "hello-world/$app" .

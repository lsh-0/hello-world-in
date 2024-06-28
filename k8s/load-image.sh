#!/bin/bash
set -euxv

app="$1"

(
    cd ../docker
    ./build.sh "$app"
)

eval $(minikube docker-env)
minikube image load "hello-world/$app:latest"

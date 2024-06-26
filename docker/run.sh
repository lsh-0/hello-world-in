#!/bin/bash
# run as a regular user.
# assumes regular user can run `docker` commands.
set -euxv

app="$1"

./build.sh "$app"

if test "$app" = "nginx"; then
    docker run \
        --rm \
        --name "hello-world-$app" \
        --publish 1234:80 \
        --volume $(realpath ../html):/usr/share/nginx/html \
        "hello-world/$app"
    exit 0

elif test "$app" = "caddy"; then
    docker run \
        --rm \
        --name "hello-world-$app" \
        --publish 1234:80 \
        --volume $(realpath ../html):/usr/share/caddy \
        "hello-world/$app"
    exit 0

elif test "$app" = "python"; then
    docker run \
        --rm \
        --name "hello-world-$app" \
        --publish 1234:80 \
        --volume $(realpath ../html):/tmp/html \
        "hello-world/$app"
    exit 0

elif test "$app" = "go"; then
    docker run \
        --rm \
        --name "hello-world-$app" \
        -it \
        --publish 1234:80 \
        --volume $(realpath ../html):/tmp/html \
        --volume $(realpath ../go):/tmp/hello-world-go \
        "hello-world/$app"
    exit 0

fi

echo "unknown app: $app"

exit 1

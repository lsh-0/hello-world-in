#!/bin/bash
set -euxv

app="$1"

if test "$app" = "nginx"; then
    docker run \
        --name "hello-world-$app" \
        --publish 1234:80 \
        --volume $(realpath ../html):/usr/share/nginx/html:ro "hello-world/$app"
    exit 0

fi

echo "unknown app: $app"

exit 1

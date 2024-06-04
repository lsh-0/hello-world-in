# "Hello, World!" in ...

Different approaches to running a webserver to serve up a simple 'Hello, World!' HTML document.

All examples are available at:

    http://localhost:1234

Modifying `./html/index.html` and refreshing your browser should reflect any changes.

The example HTML can be opened in your web browser like this:

    xdg-open ./html/index.html

## Python

    python -m http.server -d ./html 1234

## Go

    cd ./go
    go run .

## Vagrant, Nginx

    cd ./vagrant
    vagrant up
    APP=nginx vagrant provision

## Vagrant, Caddy

    cd ./vagrant
    vagrant up
    APP=caddy vagrant provision

## Vagrant, Python

    cd ./vagrant
    vagrant up
    APP=python vagrant provision

## Vagrant, Go

    cd ./vagrant
    vagrant up
    APP=go vagrant provision

## Vagrant, Salt, Nginx

    cd ./vagrant
    vagrant up
    APP=salt,nginx vagrant provision

## Vagrant, Salt, Caddy

    cd ./vagrant
    vagrant up
    APP=salt,caddy vagrant provision

## Vagrant, Ansible, Nginx

    cd ./vagrant
    vagrant up
    APP=ansible,nginx vagrant provision

## Vagrant, Ansible, Caddy

    cd ./vagrant
    vagrant up
    APP=ansible,caddy vagrant provision

## Docker, Nginx

    cd ./docker
    ./build.sh nginx
    ./run.sh nginx

## Docker, Caddy

    cd ./docker
    ./build.sh caddy
    ./run.sh caddy

## Docker, Python

    cd ./docker
    ./build.sh python
    ./run.sh python

## Docker, Go

    cd ./docker
    ./build.sh go
    ./run.sh go

## Docker-Compose, Nginx

    cd ./docker
    docker compose up nginx

## Docker-Compose, Caddy

    cd ./docker
    docker compose up caddy

## Docker-Compose, Python

    cd ./docker
    docker compose up python

## Docker-Compose, Go

    cd ./docker
    docker compose up go

## Terraform, EC2, Nginx

## Terraform, EC2, Caddy

## Cloudformation, EC2, Nginx

## Cloudformation, EC2, Caddy

## Cloudformation, EC2, Nginx, S3

## Cloudformation, S3, Cloudfront


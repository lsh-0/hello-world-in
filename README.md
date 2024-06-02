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
    APP=nginx vagrant up

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

## Vagrant, Salt, Caddy

## Vagrant, Ansible, Nginx

## Vagrant, Ansible, Caddy

## Docker, Nginx

## Docker, Caddy

## Docker, Python

## Docker, Go

## Docker-Compose, Nginx

## Docker-Compose, Caddy

## Vagrant, Docker, Nginx

## Vagrant, Docker, 

## Terraform, Vagrant, Nginx

## Terraform, EC2, Nginx

## Terraform, EC2, Caddy

## Cloudformation, EC2, Nginx

## Cloudformation, EC2, Caddy

## Cloudformation, EC2, Nginx, S3

## Cloudformation, S3, Cloudfront



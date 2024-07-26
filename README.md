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
    ./run.sh nginx

## Docker, Caddy

    cd ./docker
    ./run.sh caddy

## Docker, Python

    cd ./docker
    ./run.sh python

## Docker, Go

    cd ./docker
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

# k8s/minikube

The examples below assume `minikube` is installed.

Docker images are built locally and then loaded into minikube.

Shared directories, like `./html`, are mounted inside `minikube`.

Use this to determine the URL and fetch the result:

    minikube service hello-world-$app --url

For example:

    curl $(minikube service hello-world-python --url)

## k8s, Python

    cd ./k8s
    ./load-image.sh python
    minikube mount ../html:/html &
    kubectl apply -f python.yml

## k8s, Go

    cd ./k8s
    ./load-image.sh go
    minikube mount ../html:/html &
    minikube mount ../go:/go &
    kubectl apply -f go.yml

# AWS EC2

The below examples copy the `./html` directory remotely however changes are not reflected automatically.

Set the `region` and `vpc_id` variables in a file called `terraform.tfvars`.

If your `region` isn't `us-east-1` or `ap-southeast-2`, you'll need to modify the `ami_map` in `variables.tf`.

Create a keypair for these ec2 instances:

    ssh-keygen -f key -N ''

If you call it something other than `key` you'll need to update `terraform.tfvars`.

Clean up with `terraform destroy`.

## Terraform, EC2, Nginx

    cd ./terraform
    terraform init
    terraform plan -var-file terraform.tfvars -out terraform.plan
    terraform apply terraform.plan
    terraform output -json > outputs.json
    go run . --outputs-file outputs.json --app nginx
    xdg-open "http://$(cat outputs.json | jq .public_ip.value -r)"

## Terraform, EC2, Caddy

    cd ./terraform
    terraform init
    terraform plan -var-file terraform.tfvars -out terraform.plan
    terraform apply terraform.plan
    terraform output -json > outputs.json
    go run . --outputs-file outputs.json --app caddy
    xdg-open "http://$(cat outputs.json | jq .public_ip.value -r)"

## Terraform, EC2, Ansible, Nginx

## Terraform, EC2, Ansible, Caddy

## Cloudformation, EC2, Nginx

## Cloudformation, EC2, Caddy

## Others

* k8s?
* lambda?
* ecs?
* static website? with cloudfront?
* alb?

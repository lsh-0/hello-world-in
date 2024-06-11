terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.region
}

resource "aws_security_group" "hello_world_sg" {
    name        = "hello-world-security-group"
    description = "Security group for the hello-world ec2 instance"

    vpc_id = var.vpc_id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "hello_world_keypair" {
    key_name_prefix = "hello-world"
    public_key = file("${var.key_name}.pub")
}

resource "aws_instance" "hello_world_ec2" {
    ami           = lookup(var.ami_map, var.region)
    instance_type = "t2.micro"
    key_name      = aws_key_pair.hello_world_keypair.key_name
    vpc_security_group_ids = [
        aws_security_group.hello_world_sg.id
    ]

    tags = {
        Name = "hello-world"
    }
}

output "public_ip" {
    value = aws_instance.hello_world_ec2.public_ip
}

output "keyfile" {
    value = abspath(var.key_name)
}

output "user" {
    value = var.username
}

output "port" {
    value = 22
}


variable "region" {
    description = "the region to create resources in and to find the right AMI to use."
    type = string
    default = "us-east-1"
}

variable "vpc_id" {
    description = "ID of the VPC to create the ec2 instance and security group in."
    type = string
}

# ubuntu 22.04 AMIs for amd64
# see: https://cloud-images.ubuntu.com/locator/ec2/
variable "ami_map" {
    type = map(string)
    default = {
        us-east-1 = "ami-07543813a68cc4fe9"
        ap-southeast-2 = "ami-02ed5476230dbbf5c"
    }
}

variable "key_name" {
    description = "filename of the keypair to use. for example 'key' if 'key' and 'key.pub'"
    type = string
}

variable username {
    description = "the name of the user available on the ec2 instance"
    type = string
    default = "ubuntu"
}

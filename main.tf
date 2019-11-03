provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "piska-boss-alugar"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "ec2" {
  ami           = "ami-04b9e92b5572fa0d1"
  instance_type = "t2.micro"
  tags = {
    Name = "DanilaBidrilla-${timestamp()}"
  }
  security_groups = ["${aws_security_group.ingress-all-test.name}"]
  key_name = "deployer-key"
}

resource "aws_security_group" "ingress-all-test" {
name = "allow-all-sg"
#vpc_id = "${aws_vpc.test-env.id}"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
resource "aws_eip" "ip" {
    vpc = true
    instance = aws_instance.ec2.id
}

resource "aws_key_pair" "deployer" {
  key_name  = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwkSd4aanbiiiJrnQQWGuTKfZPh3BVhA6PKYrparDSXcWnI/wsEgvax2oSSPy1KT61pgKbYGO667EOfDG1DpoLlssE3fq7/C+j/+5x8b07beG+wUzb4uCywR62VN90gXDouUzNHYF5XF+J090t/4/dGJwiqB9stqWsW8dz3KDq4BvNIRg8XPnou1mLuyKEvMi0rX8w/s5eF157YVhwYMMPyiINgKSKZ0CR1NmSR8EARDAPIY8LHrbrnXE5tr1qNqYxsLgXQkRbtRa8GYstiaLOuQdYG4YViLiFGtKlPnpCdnyS30cU1LiXwlCrmEwqaWNEjgOLl7CKU8ihMuv11ubL adviv@DESKTOP-RHS1DE0"
}
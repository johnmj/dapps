provider "aws" {
   # access_key = "${var.aws_access_key}"
   # secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}
data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516",
    ]
  }
}

resource "aws_security_group" "security_group" {
  name = "sec_group_github_runner"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  from_port = 22
    to_port = 22
    protocol = "tcp"
  }
}

resource "aws_instance" "SGB-GH-Runner" {

  #ami                    = "ami-053b0d53c279acc90"
  ami                    = data.aws_ami.ubuntu_server.id
  instance_type          = "t2.micro"
  key_name               = "epam_edp"
  monitoring             = false
  #vpc_security_group_ids = ["sg-03553a34a1c653eed"]
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id              = "subnet-9eb5e0b4"

 #user_data = templatefile("scripts/ec2.sh", {personal_access_token = var.personal_access_token})
 user_data = templatefile("${path.module}/scripts/ec2.sh", {personal_access_token = "${var.personal_access_token}"})
	tags = {
		Name = "SGB-GitHub-Runner"	
		Type = "terraform"
	}
  provisioner "local-exec" {
    command = "echo The server IP address is ${self.private_ip} "
  }
}
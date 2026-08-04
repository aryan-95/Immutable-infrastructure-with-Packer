packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu" {

  region = var.aws_region

  instance_type = "t3.micro"

  ssh_username = "ubuntu"

  ami_name = "golden-ami-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }

    owners      = ["099720109477"]
    most_recent = true
  }
}

build {

  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",

      "sudo apt install -y nginx",

      "sudo systemctl enable nginx",

      "echo '<h1>Hello from Golden AMI</h1>' | sudo tee /var/www/html/index.html",

      "sudo systemctl restart nginx"
    ]
  }
}
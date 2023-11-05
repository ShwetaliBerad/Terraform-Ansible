terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.16.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "NginxServer"{
    ami = "ami-04cb4ca688797756f"
    instance_type = "t2.micro"
    tags = {
        name = "MyNginxServer"
    }
    key_name = "myKey"
    
    provisioner "remote-exec" {
        inline = [
            "echo 'Ready for Connection !'"
        ]

        connection {
            type = "ssh"
            user = "ec2-user"
            private_key = file("ansible/myKey.pem")
            host = self.public_ip
        }
    }
    
    provisioner "local-exec" {
    	command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ansible/myKey.pem ansible/playbook.yaml"
    }
}

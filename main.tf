provider "aws" {
    region = "us-east-1"
}


resource "aws_instance" "CCFS" {
    ami                    = "ami-0e86e20dae9224db8"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.CCFS-instance.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello our lovlies, Welcome to your favourite island food stop CCFS" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF

    tags = {
        Name = "Crawley-Carribean-Food-Service"
    }
}

resource "aws_security_group" "CCFS-instance" {

  name = "Crawley-Carribean-Food-Service-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


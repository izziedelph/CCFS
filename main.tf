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


resource "aws_launch_configuration" "CCFS" {
  image_id        = "ami-0e86e20dae9224db8"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.CCFS-instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello our lovlies, Welcome to your favourite island food stop CCFS" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "CCFS" {
  launch_configuration = aws_launch_configuration.CCFS.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
 

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-CCFS"
    propagate_at_launch = true
  }
}


data "aws_vpc" "default" {
  default = true
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


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

  target_group_arns = [aws_lb_target_group.CCFS.arn]
  health_check_type = "ELB"
 

  min_size = 0
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


resource "aws_lb" "CCFS" {

  name               = "terraform-asg-CCFS"

  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.CCFS-alb.id]
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.CCFS.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}


resource "aws_security_group" "CCFS-alb" {

  name = "CCFS-alb"

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb_target_group" "CCFS" {

  name = "terraform-asg-CCFS"

  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_listener_rule" "CCFS" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.CCFS.arn
  }
}


output "alb_dns_name" {
  value       = aws_lb.CCFS.dns_name
  description = "The domain name of the load balancer"
}

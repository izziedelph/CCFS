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
 

  min_size         = 2 # Ensure no instances are running
  max_size         = 10
  #desired_capacity = 0  # Force no instances to be running

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


resource "aws_s3_bucket" "CCFS_state" {

  bucket = "ccfs-state-bucket"

  lifecycle {
  prevent_destroy = false
  }
}


# Enable versioning so you can see the full revision history of your state files
resource "aws_s3_bucket_versioning" "CCFS-enabled" {
  bucket = aws_s3_bucket.CCFS_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "CCFS-default" {
  bucket = aws_s3_bucket.CCFS_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.CCFS_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_dynamodb_table" "CCFS-terraform_locks" {
  name         = "CCFS-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}



terraform {
  backend "s3" {
    bucket         = "ccfs-state-bucket"       
    key            = "global/s3/terraform.tfstate"  
    region         = "us-east-1"               
    dynamodb_table = "CCFS-locks"   
    encrypt        = true                        
  }
}



output "s3_bucket_arn" {
  value       = aws_s3_bucket.CCFS_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.CCFS-terraform_locks.name
  description = "The name of the DynamoDB table"
}


resource "aws_db_instance" "CCFS-db" {
  identifier_prefix   = "ccfs-example"
  engine              = "mysql"
  allocated_storage   = 20
  engine_version      = "8.0.35"
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true

  db_name             = var.db_name

  username = var.db_username
  password = var.db_password
}


output "address" {
  value       = aws_db_instance.CCFS-db.address
  description = "Connect to the database at this endpoint"
}


output "port" {
  value       = aws_db_instance.CCFS-db.port
  description = "The port the database is listening on"
}

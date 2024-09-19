provider "aws" {
    region = "us-east-1"
}


resource "aws_instance" "CCFS" {
    ami           = "ami-0e86e20dae9224db8"
    instance_type = "t2.micro"

    tags = {
        Name = "Crawley-Carribean-Food-Service"
    }
}




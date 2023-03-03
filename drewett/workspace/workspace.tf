provider "aws" {
    region = "eu-west-2"
}


#Basic Linux EC2 instance
resource "aws_instance" "linux" {
  ami                    = "ami-0aaa5410833273cfe"
  instance_type          = "t2.micro"

  tags = {
    Name = "aws-linux"
  }
}

terraform {
    backend "s3" {
        key = "workspace/s3/terraform.tfstate"        
    }    
}
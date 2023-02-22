resource "aws_instance" "linux" {
  ami           = "ami-09ee0944866c73f62"
  instance_type = "t2.micro"
  tags = {
    Name = "terraform-example"
  }
}
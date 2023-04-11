# AMI identifiers are different for each region
# but we can find one to use by using a filter
data "aws_ami" "linux_region_1" {
    provider = aws.region_1
    most_recent = true

    owners = ["099720109477"] 

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

data "aws_ami" "linux_region_2" {
    provider = aws.region_2
    most_recent = true

    owners = ["099720109477"] 

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

resource "aws_instance" "region_1_ec2" {
    provider = aws.region_1

    ami = data.aws_ami.linux_region_1.id
    instance_type = "t2.micro" 
}

resource "aws_instance" "region_2_ec2" {
    provider = aws.region_2

    ami = data.aws_ami.linux_region_2.id
    instance_type = "t2.micro" 
}

## Add out put values to check we have deploy to correct region
output "instance_region_1_az" {
    value = aws_instance.region_1_ec2.availability_zone
    description = "The AZ where the instance in the first region is deployed"
}

output "instance_region_2_az" {
    value = aws_instance.region_2_ec2.availability_zone
    description = "The AZ where the instance in the second region is deployed"
}

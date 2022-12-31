# Creating VPC 
resource "aws_vpc" "demovpc" {
cidr_block       = "10.0.0.0/16"
 instance_tenancy = "default"
tags = {
    Name = "Demo VPC"
  }
}
#creating Igw.
resource "aws_internet_gateway" "my-igw"{
vpc_id = aws_vpc.demovpc.id
}

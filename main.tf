provider "aws" {
    region_name = ap-southeast-1c
    access_key = 
    secret_key =  
}

# create vpc
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        name = "myvpc"
    }
}

# create internet gateway
resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        name = "myigw"
    }
}

# create route table
resource "aws_route_table" "route" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        name = "route1"
    }
    route = {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }
}

# create subnet
resource "aws_subnet" "my-subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-southeast-1a"
    tags = {
        name = "subnet1"
    }  
}
resource "aws_subnet" "my-subnet2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-southeast-1b"
    tags = {
        name = "subnet2"
    }  
}

# route table association
resource "aws_route_table_association" "rt" {
    subnet_id = aws_subnet.my-subnet.id
    route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "rt1" {
    subnet_id = aws_subnet.my-subnet2.id
    route_table_id = aws_route_table.route.id
}

# create security group
resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.my_vpc.id
    name = "allow web traffic"
    description = "inbound traffic to be allowed"

    ingress = {
        description = "SSH from VPC"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]   
    }
    ingress = {
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]   
    }
}

# launch ec2 instance
resource "aws_instance" "my-ec2" {
    instance_type = t2.micro
    availability_zone = ap-southeast-1b
    ami = "ami-051a81c2bd3e755db"
    key_name = "my-key"

    user_data = <<-EOF
                #!/bin/bash
                sudo yum -y install httpd
                sudo systemctl start httpd
                sudo systemctl enable httpd
                sudo bash -c 'echo hello-world > /var/www/html/index.html'
                sudo yum -y install git
                EOF
    tags = {
      "Name" = "my-instance"
    }
}

provider "aws" {
  region = "ap-southeast-2"
}

# create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}

# create internet gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "myigw"
  }
}

# create route table
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "route1"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

# create subnet
resource "aws_subnet" "my-subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet1"
  }
}
resource "aws_subnet" "my-subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2c"
  tags = {
    Name = "subnet2"
  }
}

# route table association
resource "aws_route_table_association" "rt" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.my-subnet2.id
  route_table_id = aws_route_table.route.id
}

# create security group
resource "aws_security_group" "my-sg" {
  vpc_id      = aws_vpc.my_vpc.id
  name        = "allow web traffic"
  description = "inbound traffic to be allowed"

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mysg"
  }
}

# launch ec2 instance
resource "aws_instance" "my-ec2" {
  instance_type          = "t2.micro"
  ami                    = "ami-051a81c2bd3e755db"
  vpc_security_group_ids = ["${aws_security_group.my-sg.id}"]
  subnet_id              = aws_subnet.my-subnet.id
  key_name               = "thursday"

  user_data = file("data.sh")
  tags = {
    "Name" = "my-instance"
  }
}

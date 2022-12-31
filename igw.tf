#creating Igw.
resource "aws_internet_gateway" "my-igw"{
vpc_id = aws_vpc.demo_vpc.id
}

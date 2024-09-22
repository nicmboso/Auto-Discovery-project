#vpc
resource "aws_vpc" "pet-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc-name
  }
}

#public subnets
resource "aws_subnet" "pubsn-1" {
  vpc_id            = aws_vpc.pet-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az-1

  tags = {
    Name = var.pub1-name
  }

}

resource "aws_subnet" "pubsn-2" {
  vpc_id            = aws_vpc.pet-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az-2

  tags = {
    Name = var.pub2-name
  }
}

#private subnets
resource "aws_subnet" "prvsn-1" {
  vpc_id            = aws_vpc.pet-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.az-1

  tags = {
    Name = var.prv1-name
  }
}

resource "aws_subnet" "prvsn-2" {
  vpc_id            = aws_vpc.pet-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = var.az-2

  tags = {
    Name = var.prv2-name
  }
}


#igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pet-vpc.id

  tags = {
    Name = var.igw
  }
}

#eip
resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = var.eip
  }
}

#nat
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pubsn-1.id

  tags = {
    Name = var.nat
  }
}

#public route table
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.pet-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.pub-rt
  }
}

#private route table
resource "aws_route_table" "prv_rt" {
  vpc_id = aws_vpc.pet-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.prv-rt
  }
}

#Route table associations
resource "aws_route_table_association" "rta_pub-1" {
  subnet_id      = aws_subnet.pubsn-1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "rta_pub-2" {
  subnet_id      = aws_subnet.pubsn-2.id
  route_table_id = aws_route_table.pub_rt.id
}


resource "aws_route_table_association" "rta_prv-1" {
  subnet_id      = aws_subnet.prvsn-1.id
  route_table_id = aws_route_table.prv_rt.id
}

resource "aws_route_table_association" "rta_prv-2" {
  subnet_id      = aws_subnet.prvsn-2.id
  route_table_id = aws_route_table.prv_rt.id
}

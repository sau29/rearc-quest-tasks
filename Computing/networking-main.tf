/*
Code in this file does following:
1. This is main file which has networking resources deployed. It created VPC, 2 public subnets, Interner gateways, route tables.

TODO:
1. Configure VPC Flowlogs.
2. Have Name and Tags update with variable string.
*/


# Configure VPC
resource "aws_vpc" "rearc-quest-tasks-trfm-vpc" {
  cidr_block = var.rearc-quest-tasks-trfm-vpc-cidrblock

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-vpc"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}

# Configure Subnets - 2 Public
resource "aws_subnet" "rearc-quest-tasks-trfm-subnet1-pub" {
  depends_on = [
    aws_vpc.rearc-quest-tasks-trfm-vpc
  ]

  cidr_block        = var.rearc-quest-tasks-trfm-subnet1-cidrblock
  availability_zone = var.rearc-quest-tasks-trfm-subnet1-azone
  vpc_id            = aws_vpc.rearc-quest-tasks-trfm-vpc.id

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-pubsub1"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}
resource "aws_subnet" "rearc-quest-tasks-trfm-subnet2-pub" {
  depends_on = [
    aws_vpc.rearc-quest-tasks-trfm-vpc
  ]

  cidr_block        = var.rearc-quest-tasks-trfm-subnet2-cidrblock
  availability_zone = var.rearc-quest-tasks-trfm-subnet2-azone
  vpc_id            = aws_vpc.rearc-quest-tasks-trfm-vpc.id

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-pubsub2"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}

# Configure IGW and associate it with VPC
resource "aws_internet_gateway" "rearc-quest-tasks-trfm-igw" {
  depends_on = [
    aws_vpc.rearc-quest-tasks-trfm-vpc
  ]

  vpc_id = aws_vpc.rearc-quest-tasks-trfm-vpc.id

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-igw"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}

# Configure Route Table and Configure Public Route Entry
resource "aws_route_table" "rearc-quest-tasks-trfm-routetable" {
  depends_on = [
    aws_vpc.rearc-quest-tasks-trfm-vpc,
    aws_internet_gateway.rearc-quest-tasks-trfm-igw
  ]

  vpc_id = aws_vpc.rearc-quest-tasks-trfm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rearc-quest-tasks-trfm-igw.id
  }

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-routetable"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
}

# Configure Subnets in the Route Table - Subnet1
resource "aws_route_table_association" "rearc-quest-tasks-trfm-routetable_assoc_subnet1" {
  depends_on = [
    aws_route_table.rearc-quest-tasks-trfm-routetable,
    aws_subnet.rearc-quest-tasks-trfm-subnet1-pub
  ]

  route_table_id = aws_route_table.rearc-quest-tasks-trfm-routetable.id
  subnet_id      = aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id
}

# Configure Subnets in the Route Table - Subnet2
resource "aws_route_table_association" "rearc-quest-tasks-trfm-routetable_assoc_subnet2" {
  depends_on = [
    aws_route_table.rearc-quest-tasks-trfm-routetable,
    aws_subnet.rearc-quest-tasks-trfm-subnet2-pub
  ]

  route_table_id = aws_route_table.rearc-quest-tasks-trfm-routetable.id
  subnet_id      = aws_subnet.rearc-quest-tasks-trfm-subnet2-pub.id
}


# Configure VPC Flowlogs - TODO
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.64.0"
    }
  }
}

resource "aws_vpc" "prd-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Creating a new VPC for development workloads
resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.10.0.0/16"
}

# Security group for our development web server
resource "aws_security_group" "dev-web-sg" {
  vpc_id = aws_vpc.dev-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# Security group for our production web server
resource "aws_security_group" "prd-web-sg" {
  vpc_id = aws_vpc.prd-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # allow traffic from the internet
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow traffic from the internet
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # allow all traffic to the internet
  }
}



# create NAT gateway for private subnet
resource "aws_eip" "nat-gw-eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-gw-eip.id
  subnet_id     = aws_subnet.prd-pub-subnet-1.id
}



# create t2.micro ec2 instance for development web server in us-west-2a
resource "aws_instance" "prd-web-server" {
  ami                         = "ami-07d9cf938edb0739b"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.prd-pri-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.prd-web-sg.id]
  key_name                    = "best_dir"
  availability_zone           = "us-west-2a"
  associate_public_ip_address = true


  user_data = <<EOF

  #!/bin/bash

  sudo apt-get update

  sudo apt-get install -y apache2

  sudo systemctl start apache2

  sudo systemctl enable apache2

  echo "Hello from your new Apache server!" > /var/www/html/index.html

  EOF

  tags = {
    Name = "prd-web-server-us-west-2a-private"
  }
}

# create bastion host for ssh access to private subnet
resource "aws_instance" "bastion-host" {
  ami                         = "ami-07d9cf938edb0739b"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.prd-pub-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.prd-web-sg.id]
  key_name                    = "best_dir"
  availability_zone           = "us-west-2a"
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host-us-west-2a-public"
  }
}



resource "aws_subnet" "prd-pub-subnet-1" {
  vpc_id            = aws_vpc.prd-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"


  tags = {
    Name = "prd-pub-subnet-1"
  }
}



resource "aws_subnet" "prd-pub-subnet-2" {
  vpc_id            = aws_vpc.prd-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "prd-pub-subnet-2"
  }
}

resource "aws_subnet" "prd-pub-subnet-3" {
  vpc_id            = aws_vpc.prd-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "prd-pub-subnet-3"
  }
}

resource "aws_subnet" "prd-pri-subnet-1" {
  vpc_id            = aws_vpc.prd-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "prd-pri-subnet-1"
  }
}

resource "aws_subnet" "prd-pri-subnet-2" {
  vpc_id            = aws_vpc.prd-vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "prd-pri-subnet-2"
  }
}

resource "aws_subnet" "prd-pri-subnet-3" {
  vpc_id            = aws_vpc.prd-vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "prd-pri-subnet-3"
  }
}

resource "aws_internet_gateway" "prd-igw" {
  vpc_id = aws_vpc.prd-vpc.id

  tags = {
    Name = "prd-igw"
  }
}

resource "aws_route_table" "prd-pub-rt" {
  vpc_id = aws_vpc.prd-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prd-igw.id
  }
}


resource "aws_route_table_association" "prd-pub-rt-assoc-1" {
  subnet_id      = aws_subnet.prd-pub-subnet-1.id
  route_table_id = aws_route_table.prd-pub-rt.id
}

resource "aws_route_table_association" "prd-pub-rt-assoc-2" {
  subnet_id      = aws_subnet.prd-pub-subnet-2.id
  route_table_id = aws_route_table.prd-pub-rt.id
}

resource "aws_route_table_association" "prd-pub-rt-assoc-3" {
  subnet_id      = aws_subnet.prd-pub-subnet-3.id
  route_table_id = aws_route_table.prd-pub-rt.id
}

resource "aws_route_table" "prd-pri-rt" {
  vpc_id = aws_vpc.prd-vpc.id
  route {
    cidr_block = "0.0.0.0/0" # route all traffic to the NAT gateway
    gateway_id = aws_nat_gateway.nat-gw.id
  }
}


resource "aws_route_table_association" "prd-pri-rt-assoc-1" {
  subnet_id      = aws_subnet.prd-pri-subnet-1.id
  route_table_id = aws_route_table.prd-pri-rt.id
}

resource "aws_route_table_association" "prd-pri-rt-assoc-2" {
  subnet_id      = aws_subnet.prd-pri-subnet-2.id
  route_table_id = aws_route_table.prd-pri-rt.id
}

resource "aws_route_table_association" "prd-pri-rt-assoc-3" {
  subnet_id      = aws_subnet.prd-pri-subnet-3.id
  route_table_id = aws_route_table.prd-pri-rt.id
}



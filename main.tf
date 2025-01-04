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

resource "aws_subnet" "prd-pub-subnet-1 " {
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


provider "aws" {
  region = "ap-northeast-2"
}

### vpc start ###

resource "aws_vpc" "new_vpc" {
  cidr_block  = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "NEW-VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "new_public_subnet_2a" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = "192.168.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "NEW-PUBLIC-SUBNET-2A"
  }
}

resource "aws_subnet" "new_public_subnet_2b" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = "192.168.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "NEW-PUBLIC-SUBNET-2B"
  }
}

resource "aws_subnet" "new_public_subnet_2c" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = "192.168.32.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "NEW-PUBLIC-SUBNET-2C"
  }
}

resource "aws_subnet" "new_public_subnet_2d" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = "192.168.48.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "NEW-PUBLIC-SUBNET-2D"
  }
}

resource "aws_internet_gateway" "new_igw" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = "NEW-IGW"
  }
}

resource "aws_route_table" "new_public_rtb" {
  vpc_id = aws_vpc.new_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_igw.id
  }
  tags = {
    Name = "NEW-PUBLIC-RTB"
  }
}

resource "aws_route_table_association" "new_public_subnet_2a_association" {
  subnet_id = aws_subnet.new_public_subnet_2a.id
  route_table_id = aws_route_table.new_public_rtb.id
}

resource "aws_route_table_association" "new_public_subnet_2b_association" {
  subnet_id = aws_subnet.new_public_subnet_2b.id
  route_table_id = aws_route_table.new_public_rtb.id
}

resource "aws_route_table_association" "new_public_subnet_2c_association" {
  subnet_id = aws_subnet.new_public_subnet_2c.id
  route_table_id = aws_route_table.new_public_rtb.id
}

resource "aws_route_table_association" "new_public_subnet_2d_association" {
  subnet_id = aws_subnet.new_public_subnet_2d.id
  route_table_id = aws_route_table.new_public_rtb.id
}

### vpc end ###

### ec2 start ###

resource "aws_instance" "example" {
  ami                    = "ami-0fd0765afb77bcca7"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.new_public_subnet_2a.id
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name  = "new-key"
  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl enable --now httpd
              echo "Hello, Terraform AWS_Set" > /var/www/html/index.html
              EOF

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.new_vpc.id
  name = var.security_group_name

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["123.142.252.25/32"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-sg"
  }
}

### ec2 end ###

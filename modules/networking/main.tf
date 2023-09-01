resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.app-name}-${var.env}-vpc"
  }
}

resource "aws_subnet" "sn1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn3" {
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "sn_group" {
  name = "${var.app-name}-${var.env}-sn-group"
  subnet_ids = [aws_subnet.sn1.id, aws_subnet.sn2.id, aws_subnet.sn3.id]
}

resource "aws_security_group" "sg" {
  name = "${var.app-name}-${var.env}-security-group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "https"
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.app-name}-${var.env}-rds-sg"
  vpc_id = aws_vpc.vpc.id

#  ingress {
#    from_port   = 5432
#    to_port     = 5432
#    protocol    = "tcp"
#    cidr_blocks = var.white-list-ips
#  }

  #CODE BUILD IP RANGE FOR DB MIGRATIONS
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["34.228.4.208/28"]
  }
  
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name = "${var.app-name}-${var.env}-db-parameter-group"
  family = "postgres14"
  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "route1" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.sn1.id
}

resource "aws_route_table_association" "route2" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.sn2.id
}

resource "aws_route_table_association" "route3" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.sn3.id
}

//Module zum Erstellen des VPCs mit 3 Subnets in den drei Availability-Zones in Frankfurt

variable "ident" {}
variable "environment" {}
variable "region" {}

resource "aws_vpc" "this" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name        = "${var.environment}-${var.ident}-vpc"
    Environment = "${var.environment}"
    Subject     = "${var.ident}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name        = "${var.environment}-${var.ident}-internet-gateway"
    Environment = "${var.environment}"
    Subject     = "${var.ident}"
  }
}

###### PUBLIC SUBNETS ######

resource "aws_subnet" "public_1a" {
  cidr_block = "172.16.0.0/21"
  vpc_id     = "${aws_vpc.this.id}"

  # give ec2 instances a public ip
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name        = "${var.environment}-${var.ident}-subnet-public-1a"
    Environment = "${var.environment}"
    Subject     = "${var.ident}"
  }
}

resource "aws_subnet" "public_1b" {
  cidr_block = "172.16.8.0/21"
  vpc_id     = "${aws_vpc.this.id}"

  # give ec2 instances a public ip
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"

  tags = {
    Name        = "${var.environment}-${var.ident}-subnet-public-1b"
    Environment = "${var.environment}"
    Subject     = "${var.ident}"
  }
}

resource "aws_subnet" "public_1c" {
  cidr_block = "172.16.16.0/21"
  vpc_id     = "${aws_vpc.this.id}"

  # give ec2 instances a public ip
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}c"

  tags = {
    Name        = "${var.environment}-${var.ident}-subnet-public-1c"
    Environment = "${var.environment}"
    Subject     = "${var.ident}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name        = "${var.environment}-${var.ident}-route-table-public"
    Environment = "${var.environment}"
    Subject     = "${var.ident}"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_route_table_association" "public_1a" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${aws_subnet.public_1a.id}"
}

resource "aws_route_table_association" "public_1b" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${aws_subnet.public_1b.id}"
}

resource "aws_route_table_association" "public_1c" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${aws_subnet.public_1c.id}"
}

output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

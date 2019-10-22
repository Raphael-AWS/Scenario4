# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "terraform-jenkins-s3"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
#setup Provider
provider "aws" {
  region = "${var.aws_region}"
}
#VPC
resource "aws_vpc" "vpc_tuto" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "TestVPC"
  }
}

#private subnet
resource "aws_subnet" "private_1_subnet_us-east-1a" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1a"
  tags = {
   Name =  "private Subnet 1 az 1a"
  }
}
#private subnet
resource "aws_subnet" "private_1_subnet_us-east-1a" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1a"
  tags = {
   Name =  "private Subnet 1 az 1a"
  }
}
#Create EIP for Internet Gateway
resource "aws_eip" "tuto_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

#Create NAT GW
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.tuto_eip.id}"
    subnet_id = "${aws_subnet.public_subnet_us-east-1a.id}"
    depends_on = ["aws_internet_gateway.gw"]
    tags = {
        Name = "NAT GW"
    }
}

# Private Routes

resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_tuto.id}"

    tags = {
        Name = "Private route table"
    }
}

resource "aws_route" "private_route" {
route_table_id  = "${aws_route_table.private_route_table.id}"
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

# Associate subnet private_1_subnet_us-east-1a to private route table
resource "aws_route_table_association" "pr_1_subnet_us-east-1a_association" {
    subnet_id = "${aws_subnet.private_1_subnet_us-east-1a.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

# VPN Gateway

resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = "${aws_vpc.vpc_tuto.id}"

  tags = {
    Name = "VPN Gateway"
  }
}

# Route propogation for private subnets

resource "aws_vpn_gateway_route_propagation" "vgw-private-routes" {
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

# Customer Gateway

resource "aws_customer_gateway" "customer-gate-way" {
  bgp_asn    = 65000
  ip_address = "3.216.22.73"
  type       = "ipsec.1"

  tags = {
    Name = "main-customer-gateway"
  }
}

# VPN Connection

resource "aws_vpn_connection" "vpn-connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw.id}"
  customer_gateway_id = "${aws_customer_gateway.customer-gate-way.id}"
  type                = "ipsec.1"
  static_routes_only  = true
   tags = {
    Name = "vpn-connection"
  }
}

resource "aws_vpn_connection_route" "office" {
  destination_cidr_block = "192.168.10.0/24"
  vpn_connection_id      = "${aws_vpn_connection.vpn-connection.id}"
}


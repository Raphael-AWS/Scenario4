variable "aws_region" {
  description = "AWS region for hosting our your network"
  default = "us-east-1"
}
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}
variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}
variable "aws_availability_zones" {
  default     = "us-east-1a,us-east-1b,us-east-1c,us-east-1d"
  description = "List of availability zones, use AWS CLI to find your "
}

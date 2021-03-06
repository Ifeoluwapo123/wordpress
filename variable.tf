variable "aws_region" {
  type        = string
  description = "VPC Region"
  default     = "us-east-1"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "git_access_token" {
  type        = string
  description = "Github access token"
}

variable "github_repos" {
  type = list(string)
}

variable "user" {
  type = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "public_subnet1_block" {
  description = "Public Subnet 1 CIDR"
  default     = "10.0.1.0/24"
}

variable "public_subnet2_block" {
  description = "Public Subnet 2 CIDR"
  default     = "10.0.2.0/24"
}

variable "private_subnet1_block" {
  description = "Private Subnet 1 CIDR"
  default     = "10.0.3.0/24"
}

variable "private_subnet2_block" {
  description = "Private Subnet 2 CIDR"
  default     = "10.0.4.0/24"
}

variable "public_subnet1_az" {
  description = "Public Subnet 1 Availability Zone"
  default     = "us-east-1a"
}

variable "public_subnet2_az" {
  description = "Public Subnet 2 Availability Zone"
  default     = "us-east-1b"
}

variable "key_name" {
  type = string
}

variable "machine_image" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "private_subnet1_az" {
  description = "Private Subnet 1 Availability Zone"
  default     = "us-east-1c"
}

variable "private_subnet2_az" {
  description = "Private Subnet 2 Availability Zone"
  default     = "us-east-1d"
}

variable "engine" {
  description = "RDS Engine"
  default     = "mysql"
}

variable "db_name" {
  description = "Database Name"
  default     = "blog"
}

variable "db_username" {
  description = "Database Username"
}

variable "db_password" {
  description = "Database Password"
}

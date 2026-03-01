variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR - Public Subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR -Private Subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "mongo_admin_user" {
  description = "Creation of terraform input variable"
  type        = string
  default     = "admin"
}

variable "mongo_admin_password" {
  type    = string
  default = "PaZZW0123334"
}

variable "backup_bucket_name" {
  type        = string
  description = "S3 bucket"
}

variable "public_subnet2_cidr" {
  type        = string
  description = "CIDR - Public Subnet AZ2"
  default     = "10.0.3.0/24"
}

variable "private_subnet2_cidr" {
  type        = string
  description = "CIDR - Private Subnet AZ2"
  default     = "10.0.4.0/24"
}

variable "jr_tasky_image" {
  type = string
}
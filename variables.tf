variable "vpc_cidr_block" {
  description = "VPC Subnet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1" {
  description = "VPC Subnet 1 for ALB"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_2" {
  description = "VPC Subnet 2 for ALB"
  type        = string
  default     = "10.0.2.0/24"
}

variable "is_pipeline" {
  type        = bool
  default     = false
  description = "Set to true when running inside CI/CD to bypass local profiles."
}
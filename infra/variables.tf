variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
  default     = "changeme123"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (use your IP/32)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "domain_name" {
  description = "Domain name for SSL certificate (optional)"
  type        = string
  default     = ""
}

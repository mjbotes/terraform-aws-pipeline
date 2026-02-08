data "aws_availability_zones" "available" {
  state = "available"
}

# Use default VPC instead of creating new one
data "aws_vpc" "default" {
  default = true
}

# Use default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default_subnets" {
  count = length(data.aws_subnets.default.ids)
  id    = data.aws_subnets.default.ids[count.index]
}

# Create DB subnet group using default subnets
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet"
  subnet_ids = data.aws_subnets.default.ids
  tags = {
    Name = "main-db-subnet-group"
  }
}

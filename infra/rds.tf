resource "aws_db_instance" "default" {
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = "mydb"
  username                = "admin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  backup_retention_period = 0
  delete_automated_backups = true
  deletion_protection     = false
  
  tags = {
    Environment = "demo"
    AutoShutdown = "true"
  }
}

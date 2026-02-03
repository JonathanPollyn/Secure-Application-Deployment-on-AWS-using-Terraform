resource "aws_db_subnet_group" "db" {
  name       = "secure-prod-style-db-subnet-group"
  subnet_ids = [aws_subnet.private-db-sn-1.id, aws_subnet.private-db-sn-2.id]
}

resource "aws_db_instance" "postgres" {
  identifier        = "secure-prod-style-postgres"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_encrypted = true
  username          = var.db_username
  password          = var.db_password

  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  backup_retention_period = 7
  skip_final_snapshot     = true
}
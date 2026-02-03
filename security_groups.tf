# ALB SG: 80 for HTTP and 433 for HTTPS from the internet
variable "admin_cidr" { type = string }
resource "aws_security_group" "alb_sg" {
  name   = "secure-prod-style-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 433
    to_port     = 433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  tags = {
    name = "secure-prod-style-alb-sg"
  }

}

# Bastion SG: SSH from local IP
resource "aws_security_group" "bastion_sg" {
  name   = "secure-prod-style-bastion_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secure-prod-style-bastion-sg"
  }
}

# App SG: Allow HTTP (80) from ALB SG; allow 22 from bastion SG
resource "aws_security_group" "app_sg" {
  name   = "secure-prod-style-app-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secure-prod-style-app-sg"
  }
}

# DB SG: Allows 5432 only from app sg
resource "aws_security_group" "db_sg" {
  name   = "secure-prod-style-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {

    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secure-prod-style-db-sg"
  }
}



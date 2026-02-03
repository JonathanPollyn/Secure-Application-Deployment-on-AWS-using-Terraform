resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "secure-prod-style-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "secure-prod-style-igw"
  }
}

# --==========================================
# Subnets for 2 AZ
# --==========================================
resource "aws_subnet" "public-sn-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "secure-prod-style-public-sn-1"
  }
}

resource "aws_subnet" "public-sn-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "secure-prod-style-public-sn-2"
  }

}

resource "aws_subnet" "private-app-sn-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "secure-prod-style-private-app-sn-1"
  }
}

resource "aws_subnet" "private-app-sn-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "secure-prod-style-private-app-sn-2"
  }
}

resource "aws_subnet" "private-db-sn-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.21.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "secure-prod-style-db-sn-1"
  }
}

resource "aws_subnet" "private-db-sn-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.22.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "secure-prod-style-db-sn-2"
  }
}

# --==========================================
# Route Tables
# --==========================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "secure-prod-style-public-rt"
  }
}

resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public-sn-1.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "public-1b" {
  subnet_id      = aws_subnet.public-sn-2.id
  route_table_id = aws_route_table.public.id

}

# --=============================================
# NAT for private app egress
# --=============================================
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "secure_prod_style_nat_eip"

  }
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-sn-1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "secure_prod_style_nat"
  }
}

resource "aws_route_table" "private-app" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "secure-prod-style-rt-private-app"
  }
}

resource "aws_route_table_association" "private-app-app-a" {
  subnet_id      = aws_subnet.private-app-sn-1.id
  route_table_id = aws_route_table.private-app.id
}

resource "aws_route_table_association" "private-app-app-b" {
  subnet_id      = aws_subnet.private-app-sn-2.id
  route_table_id = aws_route_table.private-app.id
}


# DB route table: No internet route
resource "aws_route_table" "private-db" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "secure-prod-style-rt-private-db"
  }
}

resource "aws_route_table_association" "private-db-a" {
  subnet_id      = aws_subnet.private-db-sn-1.id
  route_table_id = aws_route_table.private-db.id
}

resource "aws_route_table_association" "private-db-b" {
  subnet_id      = aws_subnet.private-db-sn-2.id
  route_table_id = aws_route_table.private-db.id
}

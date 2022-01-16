resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    name = "vpc-blog"
  }
}

resource "github_repository" "repos" {
  count       = length(var.github_repos)
  name        = var.github_repos[count.index]
  description = "terraform 10${count.index}"
  visibility  = "private"
}

resource "aws_subnet" "public-subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet1_block
  availability_zone = var.public_subnet1_az

  tags = {
    Name = "public-subnet-${var.public_subnet1_az}"
  }
}

resource "aws_subnet" "public-subnet2" {
  cidr_block        = var.public_subnet2_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.public_subnet2_az

  tags = {
    Name = "public-subnet-${var.public_subnet2_az}"
  }
}

resource "aws_subnet" "private-subnet1" {
  cidr_block        = var.private_subnet1_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.private_subnet1_az

  tags = {
    Name = "private-subnet-${var.private_subnet1_az}"
  }
}

resource "aws_subnet" "private-subnet2" {
  cidr_block        = var.private_subnet2_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.private_subnet2_az

  tags = {
    Name = "private-subnet-${var.private_subnet2_az}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Route table for Public subnet"
  }
}

resource "aws_route_table_association" "rt-asso-public-subnet1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "rt-asso-public-subnet2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "wpsg" {
  name        = "wpsg"
  description = "Allow Incoming HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "blog-security-group"
  }
}

resource "aws_security_group" "elbsg" {
  name        = "elbsg"
  description = "Allow Incoming HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-security-group"
  }
}

resource "aws_security_group" "dbsg" {
  name        = "dbsg"
  description = "Allow access to MySQL from WP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wpsg.id]
  }

  tags = {
    Name = "db-security-group"
  }
}

resource "aws_instance" "wb1" {
  ami                         = var.machine_image
  instance_type               = var.machine_type
  key_name                    = var.key_name
  user_data                   = file("install.sh")
  vpc_security_group_ids      = [aws_security_group.wpsg.id]
  subnet_id                   = aws_subnet.public-subnet1.id
  associate_public_ip_address = true

  tags = {
    Name = "wordpress-${var.public_subnet1_az}"
  }
}

resource "aws_instance" "wb2" {
  ami                         = var.machine_image
  instance_type               = var.machine_type
  key_name                    = var.key_name
  user_data                   = file("index.sh")
  vpc_security_group_ids      = [aws_security_group.wpsg.id]
  subnet_id                   = aws_subnet.public-subnet2.id
  associate_public_ip_address = true

  tags = {
    Name = "wordpress-${var.public_subnet2_az}"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "db-subnet-group"
  description = "RDS Subnet Group"
  subnet_ids  = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]

  tags = {
    Name = "DB Subnet Group"
  }
}

resource "aws_db_instance" "default" {
  name                    = var.db_name
  engine                  = var.engine
  engine_version          = "5.6.35"
  storage_type            = "gp2"
  allocated_storage       = 5
  instance_class          = "db.t2.micro"
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = [aws_security_group.dbsg.id]
  db_subnet_group_name    = aws_db_subnet_group.default.id
  skip_final_snapshot     = true
  backup_retention_period = 0
  apply_immediately       = true
}

resource "aws_elb" "default" {
  name                        = "elbwp"
  instances                   = [aws_instance.wb1.id, aws_instance.wb2.id]
  subnets                     = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]
  security_groups             = [aws_security_group.elbsg.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}



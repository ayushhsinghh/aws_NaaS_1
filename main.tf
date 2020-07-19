//Creating VPC
resource "aws_vpc" "MyVPC" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "MyVPC"
  }
}
//Creating Subnets
resource "aws_subnet" "PublicSubnet" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "192.168.1.0/24"


  tags = {
    Name = "PublicSubnet"
  }
}
resource "aws_subnet" "PrivateSubnet" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "192.168.2.0/24"


  tags = {
    Name = "PrivateSubnet"
  }
}
//Creating Internet Gateway
resource "aws_internet_gateway" "MyGateway" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "MyGateway"
  }
}
//Routing Table Creation & Association with Internet Gatway
resource "aws_route_table" "MyRoute" {
  vpc_id = aws_vpc.MyVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyGateway.id
  }


  tags = {
    Name = "MyRoute"
  }
}
resource "aws_route_table_association" "pubSub" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.MyRoute.id
}

//Security Group Creation for Wordpress
resource "aws_security_group" "allow_wp" {
  name        = "allow_wp"
  description = "It allow ssh,http"
  vpc_id      = aws_vpc.MyVPC.id

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
    Name = "allow_wp"
  }
}
//Security Group Creation for MySQL
resource "aws_security_group" "allow_sql" {
  name        = "allow_sql"
  description = "It allow MySQL only From WordPress "
  vpc_id      = aws_vpc.MyVPC.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_wp.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_sql"
  }
}
#To launch instance with wordpress and mysql
resource "aws_instance" "wordpress" {
  ami                         = var.wordpress_ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.allow_wp.id]
  key_name                    = var.Key_Name
  tags = {
    Name = "wordpress"
  }
}


resource "aws_instance" "mysql" {
  ami                    = var.mysql_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.PrivateSubnet.id
  vpc_security_group_ids = [aws_security_group.allow_sql.id]
  key_name               = var.Key_Name
  tags = {
    Name = "mysql"
  }
}
output "wordpress_dns" {
  value = aws_instance.wordpress.public_ip
}

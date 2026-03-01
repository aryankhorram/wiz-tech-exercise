data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "wiz_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "wiz-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wiz_vpc.id
  tags   = { Name = "wiz-igw" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.wiz_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name                     = "wiz-public-subnet"
    "kubernetes.io/role/elb" = "1"
  "kubernetes.io/cluster/wiz-eks" = "shared" }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.wiz_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name                              = "wiz-private-subnet"
    "kubernetes.io/role/internal-elb" = "1"
  "kubernetes.io/cluster/wiz-eks" = "shared" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.wiz_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "wiz-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "mongo_sg" {
  name   = "mongo-vm-sg"
  vpc_id = aws_vpc.wiz_vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "mongo"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "mongo-vm-sg" }
}

resource "aws_iam_role" "mongo_role" {
  name = "mongo-vm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "mongo_admin_attach" {
  role       = aws_iam_role.mongo_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "mongo_profile" {
  name = "mongo-vm-profile"
  role = aws_iam_role.mongo_role.name
}

data "aws_ami" "amzn2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "mongo" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  iam_instance_profile        = aws_iam_instance_profile.mongo_profile.name
  vpc_security_group_ids      = [aws_security_group.mongo_sg.id]
  associate_public_ip_address = true
  key_name                    = "wiz-exercise"
  tags                        = { Name = "mongo-vm" }
  user_data = templatefile("${path.module}/user_data.sh", {
    MONGO_USER    = var.mongo_admin_user
    MONGO_PASS    = var.mongo_admin_password
    BACKUP_BUCKET = var.backup_bucket_name
  })
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.wiz_vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name                            = "wiz-public-subnet-az2"
    "kubernetes.io/role/elb"        = "1"
    "kubernetes.io/cluster/wiz-eks" = "shared"
  }
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.wiz_vpc.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name                              = "wiz-private-subnet-az2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/wiz-eks"   = "shared"
  }
}

resource "aws_route_table_association" "public_assoc_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "wiz_private_route_table_association_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.wiz_private_route_table.id

}

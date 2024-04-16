provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "k8s_vpc"
  }
}

resource "aws_subnet" "k8s_subnet" {
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "k8s_subnet"
  }
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s_sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["2.232.192.159/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["2.232.192.159/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["2.232.192.159/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_sg"
  }
}

resource "aws_instance" "k8s_master" {
  ami                    = "ami-0b61e714d0fd856cc"
  instance_type          = "t3.small"
  key_name               = "kubernetes_cluster_key"
  subnet_id              = aws_subnet.k8s_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "K8s_Master"
  }
}

resource "aws_instance" "k8s_worker" {
  count                  = 2
  ami                    = "ami-0b61e714d0fd856cc"
  instance_type          = "t3.small"
  key_name               = "kubernetes_cluster_key"
  subnet_id              = aws_subnet.k8s_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "K8s_Worker_${count.index}"
  }
}

resource "aws_ebs_volume" "k8s_master_vol" {
  availability_zone = aws_instance.k8s_master.availability_zone
  size              = 50
  type              = "gp3"

  tags = {
    Name = "K8s_Master_Volume"
  }
}

resource "aws_ebs_volume" "k8s_worker_vol" {
  count             = 2
  availability_zone = element(aws_instance.k8s_worker.*.availability_zone, count.index)
  size              = 50
  type              = "gp3"

  tags = {
    Name = "K8s_Worker_Volume_${count.index}"
  }
}

resource "aws_volume_attachment" "k8s_master_vol_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.k8s_master_vol.id
  instance_id = aws_instance.k8s_master.id
}

resource "aws_volume_attachment" "k8s_worker_vol_attach" {
  count       = 2
  device_name = "/dev/sdh"
  volume_id   = element(aws_ebs_volume.k8s_worker_vol.*.id, count.index)
  instance_id = element(aws_instance.k8s_worker.*.id, count.index)
}

resource "aws_eip" "master_eip" {
  domain = "vpc"
}

resource "aws_eip" "worker_0_eip" {
  domain = "vpc"
}

resource "aws_eip" "worker_1_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc_master" {
  instance_id   = aws_instance.k8s_master.id
  allocation_id = aws_eip.master_eip.id
}

resource "aws_eip_association" "eip_assoc_worker_0" {
  instance_id   = aws_instance.k8s_worker[0].id
  allocation_id = aws_eip.worker_0_eip.id
}

resource "aws_eip_association" "eip_assoc_worker_1" {
  instance_id   = aws_instance.k8s_worker[1].id
  allocation_id = aws_eip.worker_1_eip.id
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s_igw"
  }
}

resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
  tags = {
    Name = "k8s_rt"
  }
}

resource "aws_route_table_association" "k8s_rta" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_rt.id

data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_vpc" "ecs_lb_lab_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-vpc"
  }
}

resource "aws_subnet" "ecs_subnet_1" {
  vpc_id                  = aws_vpc.ecs_lb_lab_vpc.id
  cidr_block              = var.subnet_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-subnet"
  }
}

resource "aws_subnet" "ecs_subnet_2" {
  vpc_id                  = aws_vpc.ecs_lb_lab_vpc.id
  cidr_block              = var.subnet_2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "lb_igw" {
  vpc_id = aws_vpc.ecs_lb_lab_vpc.id

  tags = {
    Name = "ecs-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ecs_lb_lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lb_igw.id
  }

  tags = {
    Name = "ecs-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_assoc_1" {
  subnet_id      = aws_subnet.ecs_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_assoc_2" {
  subnet_id      = aws_subnet.ecs_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_lb" "ecs_lb" {
  name               = "ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.ecs_subnet_1.id, aws_subnet.ecs_subnet_2.id]
}

resource "aws_lb_target_group" "lb_tg" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_lb_lab_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "30"
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Allow ALB traffic from public internet"
  vpc_id      = aws_vpc.ecs_lb_lab_vpc.id
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow ALB traffic to ECS"
  vpc_id      = aws_vpc.ecs_lb_lab_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "lb_http_in" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_http_from_lb" {
  security_group_id            = aws_security_group.ecs_sg.id
  referenced_security_group_id = aws_security_group.lb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allow ECS traffic from ALB"
}

resource "aws_vpc_security_group_egress_rule" "lb_out" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "ecs_out" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_iam_role" "ecs_cluster_role" {
  name = "ecs_cluster_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  role       = aws_iam_role.ecs_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task_service" {
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_cluster_role.arn
  container_definitions = jsonencode([
    {
      name      = "traefik-whoami-container"
      image     = "traefik/whoami"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_task_service" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.ecs_subnet_1.id, aws_subnet.ecs_subnet_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = "traefik-whoami-container"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.http]
}
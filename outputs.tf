output "vpc_id" {
  description = "The ID of the newly created Minecraft VPC"
  value       = aws_vpc.ecs_lb_lab_vpc.id
}

output "lb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.ecs_lb.dns_name
}

output "subnet_1_id" {
  description = "The ID of public subnet 1 where the ECS cluster will live"
  value       = aws_subnet.ecs_subnet_1.id
}

output "subnet_2_id" {
  description = "The ID of public subnet 2 where the ECS cluster will live"
  value       = aws_subnet.ecs_subnet_2.id
}

output "gateway_id" {
  description = "The ID of the internet gateway to the VPC"
  value       = aws_internet_gateway.lb_igw.id
}

output "route_table_id" {
  description = "The ID of the route table"
  value       = aws_route_table.public_rt.id
}

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.id
}
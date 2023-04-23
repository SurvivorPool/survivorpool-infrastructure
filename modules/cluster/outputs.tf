output "cluster-name" {
  value = aws_ecs_cluster.ecs.name
  description = "AWS cluster name"
}

output "cluster-arn" {
  value = aws_ecs_cluster.ecs.arn
  description = "AWS Cluster arn"
}

output "service-name" {
  value = aws_ecs_service.service.name
  description = "AWS service name"
}

output "service-arn" {
  value = aws_ecs_service.service.cluster
}

output "task-definition-arn" {
  value = aws_ecs_task_definition.td.arn
  description = "AWS task definition ARN"
}

output "task-definition-family-name" {
  value = aws_ecs_task_definition.td.family
  description = "AWS task definition family name"
}
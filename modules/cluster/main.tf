resource "aws_ecs_cluster" "ecs" {
  name = "${var.app-name}-${var.env}-cluster"
}

resource "aws_ecs_service" "service" {
  name = "${var.app-name}-${var.env}-service"
  cluster = aws_ecs_cluster.ecs.arn
  launch_type = "FARGATE"
  enable_execute_command = true
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  desired_count = 1
  task_definition = aws_ecs_task_definition.td.arn

  network_configuration {
    assign_public_ip = true
    security_groups = [var.security-group-id]
    subnets = var.subnet-ids
  }
}


resource "aws_ecs_task_definition" "td" {
  container_definitions = jsonencode([
    {
      name         = "${var.app-name}-${var.env}-container"
      image        = var.td-image-url
      cpu          = var.td-cpu-size
      memory       = var.td-memory-size
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  family                   = "${var.app-name}-${var.env}"
  requires_compatibilities = ["FARGATE"]

  cpu                = var.td-cpu-size
  memory             = var.td-memory-size
  network_mode       = "awsvpc"
  task_role_arn      = "arn:aws:iam::015085576747:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::015085576747:role/ecsTaskExecutionRole"
}
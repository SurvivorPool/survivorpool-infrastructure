resource "aws_acm_certificate" "my_certificate" {
  domain_name       = "*.survivorpool.win"  # Replace with your domain name
  validation_method = "EMAIL"
}

resource "aws_alb" "lb" {
  name = "${var.app-name}-${var.env}-lb"
  internal = false
  load_balancer_type = "application"
  subnets = var.subnet-ids 
  security_groups = [var.security-group-id]
} 

resource "aws_lb_target_group" "target_group" {
  name = "${var.app-name}-${var.env}-tg" 
  port = 80
  protocol = "HTTP"
  vpc_id =  var.vpc_id
  target_type = "ip"
  depends_on = [aws_alb.lb] 
}


resource "aws_ecs_cluster" "ecs" {
  name = "${var.app-name}-${var.env}-cluster"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.lb.arn
  port =  443
  protocol = "HTTPS"
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  certificate_arn = aws_acm_certificate.my_certificate.arn
}

resource "aws_cloudwatch_log_group" "log_group" { 
  name = "${var.app-name}-${var.env}-log-group"
}

resource "aws_cloudwatch_log_stream" "example-production-client" {
  name           = "survivorpool-server-dev-logstream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
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

  load_balancer {
    container_name = "${var.app-name}-${var.env}-container"
    container_port = 80
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  depends_on = [aws_alb.lb, aws_lb_listener.listener, aws_lb_target_group.target_group]
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
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-group         = "survivorpool-server-dev-loggroup"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
          awslogs-create-group= "true"
        }
      }
      environment: [
        {"name": "SQLALCHEMY_DATABASE_URI", "value": "postgresql+psycopg2://${var.db-user}:${var.db-password}@${var.db-url}/postgres"},
        {"name": "DATABASE_URL", "value": "postgresql+psycopg2://${var.db-user}:${var.db-password}@${var.db-url}/postgres"},
        {"name": "DB_URL", "value": "postgresql+psycopg2://${var.db-user}:${var.db-password}@${var.db-url}/postgres"},
        {"name": "DB_USER", "value": var.db-user},
        {"name": "DB_PASSWORD", "value": var.db-password},
        {"name": "SECRET_KEY", "value": var.secret-key},
        {"name": "PORT", "value": "80"},
        {"name": "COGNITO_URL", "value": var.cognito-url},
        {"name": "COGNITO_CLIENT_ID", "value": var.cognito-client-id},
        {"name": "ADMIN_EMAILS", "value": var.admin-emails}
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


terraform {
  backend "s3" {
    bucket = "terraform-state-survivorpool-prod"
    key = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  github-token = jsondecode(data.aws_secretsmanager_secret_version.prod-secrets.secret_string)["github-token"] 
  db-password = jsondecode(data.aws_secretsmanager_secret_version.prod-secrets.secret_string)["db-password"]
  db-user = jsondecode(data.aws_secretsmanager_secret_version.prod-secrets.secret_string)["db-user"]
  secret-key = jsondecode(data.aws_secretsmanager_secret_version.prod-secrets.secret_string)["secret-key"]
  certificate-arn = jsondecode(data.aws_secretsmanager_secret_version.prod-secrets.secret_string)["certificate-arn"]
  cognito-client-id = jsondecode(data.aws_secretsmanager_secret_version.prod-secrets.secret_string)["cognito-client-id"]
  admin-emails = jsondecode(data.aws_secretsmanager_secret_version.prod-secrets.secret_string)["admin-emails"] 
}



module "cognito" {
  source = "../../modules/cognito"
  pool_name          = "${var.app-name}-${var.env}-cognito"
  client_name        = "${var.app-name}-${var.env}"
  domain             = "${var.cognito-domain-name}-${var.env}"
  callback_urls      = var.cognito-callback-urls
  logout_urls        = var.cognito-logout-urls
}

module "survivorpool-networking" {
  source = "../../modules/networking"
  env = var.env
  app-name = var.app-name
  white-list-ips = var.white-list-ips
}

module "survivorpool-db" {
  source = "../../modules/rds"
  env = var.env
  app-name = var.app-name
  db-user = local.db-user
  db-password = local.db-password
  db-subnet-group-name = module.survivorpool-networking.db-subnet-name
  db-parameter-group-name = module.survivorpool-networking.db-parameter-group-name
  vpc-security-group-ids = [module.survivorpool-networking.db-security-group-id]
} 

module "survivorpool-repository" {
  source = "../../modules/ecr"
  env = var.env
  app-name = var.app-name
}

module "survivorpool-cluster" {
  source = "../../modules/cluster"
  env = var.env
  app-name = var.app-name
  security-group-id = module.survivorpool-networking.security-group.id
  subnet-ids = module.survivorpool-networking.subnet-ids
  td-image-url = module.survivorpool-repository.repository-url
  td-cpu-size = 256
  td-memory-size = 512
  db-url = module.survivorpool-db.database-url
  db-password = local.db-password
  db-user = local.db-user
  secret-key = local.secret-key
  db-name = module.survivorpool-db.database-name
  vpc_id = module.survivorpool-networking.vpc_id
  certificate-arn = local.certificate-arn
  cognito-url = var.cognito-url
  cognito-client-id = local.cognito-client-id
  admin-emails = local.admin-emails
}


module "survivorpool-cicd-pipeline" {
  source = "../../modules/pipeline"
  env               = var.env
  app-name          = var.app-name
  github-token    = local.github-token
  repo-name       = var.repo-name
  repo-owner-name = var.repo-owner
  branch-name = "main"
  cluster-name = module.survivorpool-cluster.cluster-name
  container-name = var.container-name
  image-tag = "latest"
  service-name = module.survivorpool-cluster.service-name
  task-def-arn = module.survivorpool-cluster.task-definition-arn
  image-repo-name = module.survivorpool-repository.ecr-repository-name
  region            = var.region
  repository-id = module.survivorpool-repository.ecr-repository-id
  cluster-arn = module.survivorpool-cluster.cluster-arn
  service-arn = module.survivorpool-cluster.service-arn
  repository-url = var.github-url
  env-variables = {
    AWS_ACCOUNT_ID = var.aws-account-id
    AWS_DEFAULT_REGION = var.aws-default-region
    IMAGE_REPO_NAME = module.survivorpool-repository.ecr-repository-name
    IMAGE_TAG = "latest"
    ECS_SERVICE_NAME = module.survivorpool-cluster.service-name
    ECS_CLUSTER_NAME = module.survivorpool-cluster.cluster-name
    ECS_TASK_DEFINITION = module.survivorpool-cluster.task-definition-family-name
    APP_NAME = var.app-name
    ENV = var.env
    DATABASE_HOST = module.survivorpool-db.database-url
    DATABASE_URL = "postgresql+psycopg2://${local.db-user}:${local.db-password}@${module.survivorpool-db.database-url}/postgres"
    SQLALCHEMY_DATABASE_URI = "postgresql+psycopg2://${local.db-user}:${local.db-password}@${module.survivorpool-db.database-url}/postgres"
    DATABASE_PASSWORD = local.db-password
    DB_PASSWORD = local.db-password
    DB_USER = local.db-user
    DATABASE_USER = local.db-user
    DATABASE_NAME = module.survivorpool-db.database-name
    PORT = "80"
    SECRET_KEY = local.secret-key
    COGNITO_URL = var.cognito-url
    COGNITO_CLIENT_ID = local.cognito-client-id
    ADMIN_EMAILS = local.admin-emails
  }
}
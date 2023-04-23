terraform {
  backend "s3" {
    bucket = "terraform-state-fitba"
    key = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

module "runba-networking" {
  source = "../../modules/networking"
  env = var.env
  app-name = var.runba-app-name  
  white-list-ips = var.white-list-ips
}

module "runba-repository" {
  source = "../../modules/ecr"
  env = var.env
  app-name = var.runba-app-name
}

module "runba-cluster" {
  source = "../../modules/cluster"
  env = var.env
  app-name = var.runba-app-name
  security-group-id = module.runba-networking.security-group.id
  subnet-ids = module.runba-networking.subnet-ids
  td-image-url = module.runba-repository.repository-url
  td-cpu-size = 256
  td-memory-size = 512
}

module "runba-db" {
  source = "../../modules/rds"
  env = var.env
  app-name = var.runba-app-name
  db-user = var.runba-db-user
  db-password = var.runba-db-password
  db-subnet-group-name = module.runba-networking.db-subnet-name
  db-parameter-group-name = module.runba-networking.db-parameter-group-name
  vpc-security-group-ids = [module.runba-networking.db-security-group-id]
}

module "runba-cicd-pipeline" {
  source = "../../modules/pipeline" 
  env               = var.env
  app-name          = var.runba-app-name
  github-token    = var.github-token
  repo-name       = var.runba-repo-name
  repo-owner-name = var.runba-repo-owner
  branch-name = var.runba-branch
  cluster-name = module.runba-cluster.cluster-name
  container-name = var.runba-server-container-name
  image-tag = "latest"
  service-name = module.runba-cluster.service-name
  task-def-arn = module.runba-cluster.task-definition-arn
  image-repo-name = module.runba-repository.ecr-repository-name
  region            = var.runba-server-region
  repository-id = module.runba-repository.ecr-repository-id
  cluster-arn = module.runba-cluster.cluster-arn
  service-arn = module.runba-cluster.service-arn
  repository-url = var.runba-github-url
  env-variables = {
    AWS_ACCOUNT_ID = var.aws-account-id
    AWS_DEFAULT_REGION = var.aws-default-region
    IMAGE_REPO_NAME = module.runba-repository.ecr-repository-name
    IMAGE_TAG = "latest"
    ECS_SERVICE_NAME = module.runba-cluster.service-name
    ECS_CLUSTER_NAME = module.runba-cluster.cluster-name
    ECS_TASK_DEFINITION = module.runba-cluster.task-definition-family-name
    APP_NAME = var.runba-app-name
    ENV = var.env
    DATABASE_HOST = module.runba-db.database-url
    DATABASE_URL = module.runba-db.database-url
    DATABASE_PASSWORD = var.runba-db-password
    DATABASE_USER = var.runba-db-user
    DATABASE_NAME = module.runba-db.database-name
  }
}

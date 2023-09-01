data "aws_secretsmanager_secret_version" "prod-secrets" {
    secret_id = "survivorpool-server/prod"
}
data "aws_secretsmanager_secret_version" "dev-secrets" {
    secret_id = "survivorpool-server/dev"
}
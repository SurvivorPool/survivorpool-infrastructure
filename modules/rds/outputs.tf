output "database-url" {
  value = aws_db_instance.postgres-db-instance.endpoint 
}

output "database-name" {
  value = aws_db_instance.postgres-db-instance.identifier
}

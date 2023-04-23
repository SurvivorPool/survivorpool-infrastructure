output "security-group" {
  value = aws_security_group.sg
  description = "AWS Security Group"
}

output "subnet-ids" {
  value = [aws_subnet.sn1.id, aws_subnet.sn2.id, aws_subnet.sn3.id]
  description = "AWS Subnet Ids"
}

output "db-subnet-name" {
  value = aws_db_subnet_group.sn_group.name
}

output "db-parameter-group-name" {
  value = aws_db_parameter_group.db_parameter_group.name
}

output "db-security-group-id" {
  value = aws_security_group.rds.id
}
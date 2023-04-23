resource "aws_db_instance" "postgres-db-instance" {
  allocated_storage    = 20
  db_subnet_group_name = var.db-subnet-group-name
  engine               = "postgres"
  engine_version       = "14.6"
  identifier           = "${var.app-name}-${var.env}-db"
  instance_class       = var.db-instance-class
  password             = var.db-password
  skip_final_snapshot  = true
  storage_encrypted    = false
  publicly_accessible  = true
  username             = var.db-user
  apply_immediately = true
  parameter_group_name = var.db-parameter-group-name
  vpc_security_group_ids  = var.vpc-security-group-ids
}
variable "env" {
  type = string
  default = "dev"
}

variable "app-name" {
  type = string 
}

variable "db-user" {
  type = string
}

variable "db-password" {
  type = string
}

variable "db-instance-class" {
  type = string
  default= "db.t3.micro"
}

variable "db-subnet-group-name" {
  type = string
}

variable "db-parameter-group-name" {
  type = string
}

variable "vpc-security-group-ids" {
  type = list(string)
}
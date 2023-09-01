variable "env" {
  type = string
  default = "dev"
}

variable "app-name" {
  type = string
} 

variable "vpc_id" {
  type = string
}

variable "security-group-id" {
  type = string 
}

variable "subnet-ids" {
  type = list
}

variable "td-image-url" {
  type = string
}

variable "td-cpu-size" {
  type = number
  default = 256
}

variable "td-memory-size" {
  type = number 
  default = 512
}

variable "db-name" {
  type = string
}

variable "db-url" {
  type = string
}

variable "db-user" {
  type = string
}

variable "db-password" {
  type = string
}

variable "secret-key" {
  type = string
}

variable "certificate-arn" {
  type = string
}

variable "cognito-url" {
  type = string
}

variable "cognito-client-id" {
  type = string
}

variable "admin-emails" {
    type = string
}
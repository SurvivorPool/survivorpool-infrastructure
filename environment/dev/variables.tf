variable "env" {
  type = string
  default = "dev"
}

variable "aws-account-id" {
  type = string
}

variable "aws-default-region" {
  type = string
}

variable "runba-app-name" {
  type = string
  default = "runba-server"
}

variable "runba-db-user" {
  type = string
}

variable "runba-db-password" {
  type = string
}

variable "github-token" {
  type = string
}

variable "runba-repo-name" {
  type = string
  default = "runba-server"
}

variable "runba-repo-owner" {
  default = "alexberardi"
}

variable "runba-branch" {
  default = "main"
}
variable "runba-github-url" {
  default = "https://github.com/alexberardi/runba-server"
}

variable "runba-repo-webhook-token" {
  type = string
}

variable "runba-server-container-name" {
  default = "runba-server"
}

variable "runba-server-region" {
  default = "us-east-1"
}

variable "white-list-ips" {
  default = []
}
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

variable "app-name" {
  type = string
}

variable "repo-name" {
  type = string
}

variable "repo-owner" {
  type = string
}

variable "branch" {
  type = string
}

variable "github-url" {
  type = string
}
variable "container-name" {
  type = string
}

variable "region" {
  type = string
}

variable "white-list-ips" {
  default = []
}

variable cognito-domain-name {
  type = string
}

variable cognito-callback-urls {
  type = list(string)
}

variable cognito-logout-urls {
  type = list(string)
}
variable cognito-url {
  type = string
}

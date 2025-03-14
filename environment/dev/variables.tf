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

# variable "db-user" {
#   type = string
# }

# variable "db-password" {
#   type = string
# }

# variable "github-token" {
#   type = string
# }

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

# variable "repo-webhook-token" {
#   type = string
# }

variable "container-name" {
  type = string
}

variable "region" {
  type = string
}

variable "white-list-ips" {
  default = []
}

# variable "secret-key" {
#   type = string
# }

# variable "certificate-arn" {
#   type = string
# }

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

# variable cognito-client-id {
#   type = string
# }

# variable admin-emails {
#     type = string
# }
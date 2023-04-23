variable env {
  type = string
}

variable app-name {
  type = string
}

variable repo-owner-name {
  type = string
}

variable repo-name {
  type = string
}

variable branch-name {
  type = string
  default = "dev"
}

variable github-token {
  type = string
}

variable cluster-name {
  type = string
}

variable cluster-arn {
  type = string
}

variable service-name {
  type = string
}

variable service-arn {
  type = string
}

variable task-def-arn {
  type = string
}

variable container-name {
  type = string
}

variable image-tag {
  type = string
}

variable region {
  type = string
}

variable image-repo-name {
  type = string
}

variable repository-id {
  type = string
}
variable repository-url {
  type = string
}
variable env-variables {
  type = map(string)
  default = {}
}
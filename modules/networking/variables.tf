variable "app-name" {
  type = string
  description = "Name of application"
}

variable "env" { 
  type = string
  default = "dev"
}

variable "white-list-ips" {
  type = list(string)
}


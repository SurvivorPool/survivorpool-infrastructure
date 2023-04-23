variable "env" {
  type = string
  default = "dev"
}

variable "app-name" {
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
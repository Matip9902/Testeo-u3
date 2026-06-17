variable "aws_region" {
  default = "us-east-1"
}

variable "nombre_proyecto" {
  default = "innovatech-spa"
}

variable "backend_ecr_repository_name" {
  default = "innovatech-spa-backend"
}

variable "frontend_ecr_repository_name" {
  default = "innovatech-spa-frontend"
}

variable "db_user" {}
variable "db_password" {}
variable "db_name" {}
variable "key_pair_name" {}

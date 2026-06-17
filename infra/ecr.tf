resource "aws_ecr_repository" "backend" {
  name = var.backend_ecr_repository_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  tags = {
    Name = var.backend_ecr_repository_name
  }
}

resource "aws_ecr_repository" "frontend" {
  name = var.frontend_ecr_repository_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  tags = {
    Name = var.frontend_ecr_repository_name
  }
}

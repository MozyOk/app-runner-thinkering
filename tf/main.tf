provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Env  = terraform.workspace
      Name = var.service_name
    }
  }
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = "${terraform.workspace}-${var.service_name}-erc"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
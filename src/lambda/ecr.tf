# ---------------------------------------------------------------------------------------------------------------------
# ECR
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "image_repo" {
  name                 = var.image_repo_name
  image_tag_mutability = "MUTABLE"

  #  image_scanning_configuration {
  #    scan_on_push = true
  #  }

  tags = { Name = var.image_repo_name }
}


output "lambda_image_repo_url" {
  value = aws_ecr_repository.image_repo.repository_url
}

output "lambda_image_repo_arn" {
  value = aws_ecr_repository.image_repo.arn
}


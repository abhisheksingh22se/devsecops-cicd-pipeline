resource "aws_ecr_repository" "app_repo" {
  name                 = "devsecops-demo"
  image_tag_mutability = "MUTABLE" # Must be mutable if overwriting 'latest' or 'rc-latest'

  # AWS native vulnerability scanning on push
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}

# Keep only the last 30 images to manage storage costs
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 30
      }
      action = {
        type = "expire"
      }
    }]
  })
}
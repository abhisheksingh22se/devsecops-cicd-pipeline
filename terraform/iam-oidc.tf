# ── Data Sources ──────────────────────────────────────────────────────────────
data "aws_caller_identity" "current" {}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main",
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/develop",
        "repo:${var.github_org}/${var.github_repo}:pull_request",
      ]
    }
  }
}

data "aws_iam_policy_document" "ecr_push" {
  statement {
    sid       = "ECRAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPush"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}

# ── OIDC Identity Provider ────────────────────────────────────────────────────
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]

  tags = {
    Project     = "devsecops-pipeline"
    ManagedBy   = "terraform"
  }
}

# ── IAM Role ──────────────────────────────────────────────────────────────────
resource "aws_iam_role" "github_actions" {
  name               = "GitHubActionsOIDCRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  description        = "OIDC role for GitHub Actions — zero static credentials"

  tags = {
    Project   = "devsecops-pipeline"
    ManagedBy = "terraform"
  }
}

# ── IAM Role Policy ───────────────────────────────────────────────────────────
resource "aws_iam_role_policy" "ecr_push" {
  name   = "ECRPushPolicy"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.ecr_push.json
}

# ── IRSA Role for EKS Pods ────────────────────────────────────────────────────
resource "aws_iam_role" "irsa" {
  name = "devsecops-app-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:prod:devsecops-app-sa"
          "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Project   = "devsecops-pipeline"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "irsa_ecr" {
  role       = aws_iam_role.irsa.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "github_actions_role_arn" {
  description = "IAM Role ARN — set as AWS_ROLE_ARN GitHub secret"
  value       = aws_iam_role.github_actions.arn
}

output "irsa_role_arn" {
  description = "IRSA Role ARN — annotate on serviceaccount.yaml"
  value       = aws_iam_role.irsa.arn
}
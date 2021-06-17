## IAM Role - for AppRunner
data "aws_iam_policy" "AWSAppRunnerServicePolicyForECRAccess" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_iam_role" "for_app_runner" {
  name        = "${terraform.workspace}-${var.service_name}-AppRunnerECRAccessRole"
  description = "This role gives App Runner permission to access ECR"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "build.apprunner.amazonaws.com"
          ]
        }
      },
    ]
  })
}

## Attach Policy to Role
resource "aws_iam_role_policy_attachment" "app_runner" {
  role       = aws_iam_role.for_app_runner.name
  policy_arn = data.aws_iam_policy.AWSAppRunnerServicePolicyForECRAccess.arn
}

# deploy user
## IAM User
resource "aws_iam_user" "deploy_app_runner" {
  name = "deploy_app_runner"
}

## IAM Policy
resource "aws_iam_policy" "for_deploy_app_runner" {
  name        = "${terraform.workspace}-${var.service_name}-deploy-policy"
  description = "ECR push and App Runner operations Policy."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "apprunner:ListServices",
          "apprunner:CreateService",
          "iam:PassRole",
          "iam:CreateServiceLinkedRole",
        ]
        Resource = "*"
      }
    ]
  })
}

## attach Policy
resource "aws_iam_user_policy_attachment" "deploy_app_runner" {
  user       = aws_iam_user.deploy_app_runner.name
  policy_arn = aws_iam_policy.for_deploy_app_runner.arn
}
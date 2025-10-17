# Core identity
data "aws_caller_identity" "current" {}

# Existing IAM roles (only when not creating corresponding resources)
data "aws_iam_role" "lambda_existing" {
  count = var.create_lambda_role ? 0 : 1
  name  = var.existing_lambda_role_name
}

data "aws_iam_role" "apprunner_existing" {
  count = var.create_apprunner_roles ? 0 : 1
  name  = var.existing_apprunner_role_name
}

data "aws_iam_role" "apprunner_ecr_access_existing" {
  count = var.create_apprunner_roles ? 0 : 1
  name  = var.existing_apprunner_ecr_access_role_name
}

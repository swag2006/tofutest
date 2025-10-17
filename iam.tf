# Lambda IAM Role & Policy (conditional)
resource "aws_iam_role" "lambda_role" {
  count = var.create_lambda_role ? 1 : 0
  name  = "${var.project_name}-lambda-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  count = var.create_lambda_role ? 1 : 0
  name  = "${var.project_name}-lambda-policy"
  role  = aws_iam_role.lambda_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = ["s3:GetObject","s3:PutObject","s3:DeleteObject","s3:ListBucket"], Resource = [var.create_s3_bucket ? aws_s3_bucket.media[0].arn : "arn:aws:s3:::${var.existing_s3_bucket_name}", var.create_s3_bucket ? "${aws_s3_bucket.media[0].arn}/*" : "arn:aws:s3:::${var.existing_s3_bucket_name}/*"] },
      { Effect = "Allow", Action = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:Query","dynamodb:Scan"], Resource = local.dynamodb_table_arn }
    ]
  })
}

# App Runner roles (conditional)
resource "aws_iam_role" "apprunner_role" {
  count = var.create_apprunner_roles ? 1 : 0
  name  = "${var.project_name}-apprunner-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "tasks.apprunner.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "apprunner_policy" {
  count = var.create_apprunner_roles ? 1 : 0
  name  = "${var.project_name}-apprunner-policy"
  role  = aws_iam_role.apprunner_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["s3:GetObject","s3:PutObject","s3:ListBucket"], Resource = [var.create_s3_bucket ? aws_s3_bucket.media[0].arn : "arn:aws:s3:::${var.existing_s3_bucket_name}", var.create_s3_bucket ? "${aws_s3_bucket.media[0].arn}/*" : "arn:aws:s3:::${var.existing_s3_bucket_name}/*"] },
      { Effect = "Allow", Action = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:DeleteItem","dynamodb:Query","dynamodb:Scan"], Resource = local.dynamodb_table_arn }
    ]
  })
}

resource "aws_iam_role" "apprunner_ecr_access" {
  count = var.create_apprunner_roles ? 1 : 0
  name  = "${var.project_name}-apprunner-ecr-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "build.apprunner.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  count      = var.create_apprunner_roles ? 1 : 0
  role       = aws_iam_role.apprunner_ecr_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}


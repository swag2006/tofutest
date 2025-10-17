# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Existing roles (only when not creating)
data "aws_iam_role" "lambda_existing" { count = var.create_lambda_role ? 0 : 1 name = var.existing_lambda_role_name }
data "aws_iam_role" "apprunner_existing" { count = var.create_apprunner_roles ? 0 : 1 name = var.existing_apprunner_role_name }
data "aws_iam_role" "apprunner_ecr_access_existing" { count = var.create_apprunner_roles ? 0 : 1 name = var.existing_apprunner_ecr_access_role_name }

###############################################################################
# S3 Bucket
###############################################################################

resource "aws_s3_bucket" "media" { count = var.create_s3_bucket ? 1 : 0 bucket = "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}" }

resource "aws_s3_bucket_versioning" "media" { count = var.create_s3_bucket ? 1 : 0 bucket = aws_s3_bucket.media[0].id versioning_configuration { status = "Disabled" } }

resource "aws_s3_bucket_cors_configuration" "media" { count = var.create_s3_bucket ? 1 : 0 bucket = aws_s3_bucket.media[0].id cors_rule { allowed_headers = ["*"] allowed_methods = ["PUT","POST","GET"] allowed_origins = ["*"] expose_headers=["ETag"] max_age_seconds=3000 } }

resource "aws_s3_bucket_lifecycle_configuration" "media" { count = var.create_s3_bucket ? 1 : 0 bucket = aws_s3_bucket.media[0].id rule { id="expire-old-results" status="Enabled" filter { prefix="results/" } expiration { days=30 } } }

###############################################################################
# DynamoDB Table
###############################################################################

resource "aws_dynamodb_table" "jobs" {
  name           = "${var.project_name}-jobs-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "job_id"
  
  attribute {
    name = "job_id"
    type = "S"
  }
  
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
  
  point_in_time_recovery {
    enabled = var.environment == "prod"
  }
}

###############################################################################
# Lambda IAM Role and Policy
###############################################################################

resource "aws_iam_role" "lambda_role" { count = var.create_lambda_role ? 1 : 0 name = "${var.project_name}-lambda-${var.environment}" assume_role_policy = jsonencode({Version="2012-10-17" Statement=[{Action="sts:AssumeRole" Effect="Allow" Principal={Service="lambda.amazonaws.com"}}]}) }

resource "aws_iam_role_policy" "lambda_policy" { count = var.create_lambda_role ? 1 : 0 name="${var.project_name}-lambda-policy" role=aws_iam_role.lambda_role[0].id policy = jsonencode({Version="2012-10-17" Statement=[{Effect="Allow" Action=["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"] Resource="arn:aws:logs:*:*:*"},{Effect="Allow" Action=["s3:GetObject","s3:PutObject","s3:DeleteObject","s3:ListBucket"] Resource=[var.create_s3_bucket ? aws_s3_bucket.media[0].arn : "arn:aws:s3:::${var.existing_s3_bucket_name}", var.create_s3_bucket ? "${aws_s3_bucket.media[0].arn}/*" : "arn:aws:s3:::${var.existing_s3_bucket_name}/*"]},{Effect="Allow" Action=["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:Query","dynamodb:Scan"] Resource=aws_dynamodb_table.jobs.arn}]}) }

###############################################################################
# Lambda Function
###############################################################################

resource "aws_lambda_function" "processor" {
  function_name = "${var.project_name}-processor-${var.environment}"
  role          = local.lambda_role_arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = var.lambda_timeout_seconds
  memory_size   = var.lambda_memory_mb
  
  # Placeholder code - will be updated via deployment script
  filename      = "lambda_placeholder.zip"
  
  environment {
    variables = {
      S3_BUCKET_NAME       = local.bucket_name
      DYNAMODB_TABLE_NAME  = aws_dynamodb_table.jobs.name
      ADAPTER_TYPE         = var.adapter_type
      OPENAI_API_KEY       = var.openai_api_key
    }
  }
  
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.processor.function_name}"
  retention_in_days = var.environment == "prod" ? 30 : 7
}

###############################################################################
# S3 Event Trigger for Lambda
###############################################################################

resource "aws_lambda_permission" "allow_s3" { count = var.create_s3_bucket ? 1 : 0 statement_id="AllowExecutionFromS3" action="lambda:InvokeFunction" function_name=aws_lambda_function.processor.function_name principal="s3.amazonaws.com" source_arn = var.create_s3_bucket ? aws_s3_bucket.media[0].arn : "arn:aws:s3:::${var.existing_s3_bucket_name}" }

resource "aws_s3_bucket_notification" "media_events" { count = var.create_s3_bucket ? 1 : 0 bucket = aws_s3_bucket.media[0].id lambda_function { lambda_function_arn = aws_lambda_function.processor.arn events=["s3:ObjectCreated:*"] filter_prefix="media-in/" } depends_on=[aws_lambda_permission.allow_s3] }

###############################################################################
# ECR Repository for API Container
###############################################################################

resource "aws_ecr_repository" "api" { count = var.create_ecr_repo ? 1 : 0 name="${var.project_name}-api-${var.environment}" image_tag_mutability="MUTABLE" image_scanning_configuration { scan_on_push = true } }

resource "aws_ecr_lifecycle_policy" "api" { count = var.create_ecr_repo ? 1 : 0 repository = aws_ecr_repository.api[0].name policy = jsonencode({rules=[{rulePriority=1 description="Keep last 5 images" selection={tagStatus="any" countType="imageCountMoreThan" countNumber=5} action={type="expire"}}]}) }

###############################################################################
# App Runner IAM Role
###############################################################################

resource "aws_iam_role" "apprunner_role" { count = var.create_apprunner_roles ? 1 : 0 name="${var.project_name}-apprunner-${var.environment}" assume_role_policy = jsonencode({Version="2012-10-17" Statement=[{Action="sts:AssumeRole" Effect="Allow" Principal={Service="tasks.apprunner.amazonaws.com"}}]}) }

resource "aws_iam_role_policy" "apprunner_policy" { count = var.create_apprunner_roles ? 1 : 0 name="${var.project_name}-apprunner-policy" role=aws_iam_role.apprunner_role[0].id policy = jsonencode({Version="2012-10-17" Statement=[{Effect="Allow" Action=["s3:GetObject","s3:PutObject","s3:ListBucket"] Resource=[var.create_s3_bucket ? aws_s3_bucket.media[0].arn : "arn:aws:s3:::${var.existing_s3_bucket_name}", var.create_s3_bucket ? "${aws_s3_bucket.media[0].arn}/*" : "arn:aws:s3:::${var.existing_s3_bucket_name}/*"]},{Effect="Allow" Action=["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:DeleteItem","dynamodb:Query","dynamodb:Scan"] Resource=aws_dynamodb_table.jobs.arn}]}) }

resource "aws_iam_role" "apprunner_ecr_access" { count = var.create_apprunner_roles ? 1 : 0 name="${var.project_name}-apprunner-ecr-${var.environment}" assume_role_policy = jsonencode({Version="2012-10-17" Statement=[{Action="sts:AssumeRole" Effect="Allow" Principal={Service="build.apprunner.amazonaws.com"}}]}) }

resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" { count = var.create_apprunner_roles ? 1 : 0 role=aws_iam_role.apprunner_ecr_access[0].name policy_arn="arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess" }

###############################################################################
# App Runner Service
###############################################################################

resource "aws_apprunner_service" "api" { count = (var.deploy_api && var.create_apprunner_service) ? 1 : 0 service_name="${var.project_name}-api-${var.environment}" source_configuration { authentication_configuration { access_role_arn = local.apprunner_ecr_access_role_arn } image_repository { image_identifier = "${local.ecr_repository_url}:latest" image_repository_type="ECR" image_configuration { port="8080" runtime_environment_variables = { S3_BUCKET_NAME = local.bucket_name DYNAMODB_TABLE_NAME = aws_dynamodb_table.jobs.name AWS_DEFAULT_REGION = var.aws_region } } } auto_deployments_enabled = true } instance_configuration { cpu=var.api_cpu memory=var.api_memory_mb instance_role_arn=local.apprunner_role_arn } health_check_configuration { protocol="HTTP" path="/health" interval=10 timeout=5 healthy_threshold=1 unhealthy_threshold=3 } }

###############################################################################
# Create placeholder Lambda zip
###############################################################################

resource "null_resource" "create_lambda_placeholder" { provisioner "local-exec" { command = <<-EOT
      echo 'def lambda_handler(event, context): return {"statusCode": 200}' > handler_placeholder.py
      zip lambda_placeholder.zip handler_placeholder.py
      rm handler_placeholder.py
    EOT } }

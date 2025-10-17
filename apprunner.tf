# App Runner Service (conditional)
resource "aws_apprunner_service" "api" {
  count = (var.deploy_api && var.create_apprunner_service) ? 1 : 0
  service_name = "${var.project_name}-api-${var.environment}"
  source_configuration {
    authentication_configuration { access_role_arn = local.apprunner_ecr_access_role_arn }
    image_repository {
      image_identifier      = "${local.ecr_repository_url}:${var.apprunner_image_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port = "8080"
        runtime_environment_variables = {
          S3_BUCKET_NAME      = local.bucket_name
          DYNAMODB_TABLE_NAME = local.dynamodb_table_name
          AWS_DEFAULT_REGION  = var.aws_region
        }
      }
    }
    auto_deployments_enabled = true
  }
  instance_configuration {
    cpu               = var.api_cpu
    memory            = var.api_memory_mb
    instance_role_arn = local.apprunner_role_arn
  }
  health_check_configuration {
    protocol = "HTTP"
    path     = "/health"
    interval = 10
    timeout  = 5
    healthy_threshold   = 1
    unhealthy_threshold = 3
  }
  precondition {
    condition     = !((var.deploy_api && var.create_apprunner_service) && !var.create_apprunner_roles && (length(var.existing_apprunner_role_name) == 0 || length(var.existing_apprunner_ecr_access_role_name) == 0))
    error_message = "existing_apprunner_role_name and existing_apprunner_ecr_access_role_name must be provided when create_apprunner_roles=false and App Runner service enabled."
  }
  precondition {
    condition     = !((var.deploy_api && var.create_apprunner_service) && !var.create_ecr_repo && length(var.existing_ecr_repository_url) == 0)
    error_message = "existing_ecr_repository_url must be provided when create_ecr_repo=false and App Runner service enabled."
  }
  precondition {
    condition     = var.create_dynamodb_table || (length(var.existing_dynamodb_table_name) > 0 && length(var.existing_dynamodb_table_arn) > 0)
    error_message = "existing_dynamodb_table_name and existing_dynamodb_table_arn must be provided when create_dynamodb_table=false."
  }
}

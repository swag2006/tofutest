output "instructions" {
  description = "Post-deployment instructions (shown when deploy_api=true)."
  value = var.deploy_api ? join("\n", [
    "Infrastructure Initialized Successfully!",
    "",
    "Next Steps:",
    "",
    "1. Define your AWS resources in separate *.tf files.",
    "2. Run: tofu plan",
    "3. Apply: tofu apply -auto-approve",
    "4. Update this output with real resource references once they exist."
  ]) : ""
}

output "bucket_name" { value = local.bucket_name }
output "lambda_role_name" { value = length(aws_iam_role.lambda_role) > 0 ? aws_iam_role.lambda_role[0].name : var.existing_lambda_role_name }
output "apprunner_role_name" { value = length(aws_iam_role.apprunner_role) > 0 ? aws_iam_role.apprunner_role[0].name : var.existing_apprunner_role_name }
output "apprunner_ecr_access_role_name" { value = length(aws_iam_role.apprunner_ecr_access) > 0 ? aws_iam_role.apprunner_ecr_access[0].name : var.existing_apprunner_ecr_access_role_name }
output "apprunner_service_url" { value = length(aws_apprunner_service.api) > 0 ? aws_apprunner_service.api[0].service_url : "" }
output "ecr_repository_url" { value = local.ecr_repository_url }
output "lambda_function_name" { value = aws_lambda_function.processor.function_name }
output "dynamodb_table_name" { value = local.dynamodb_table_name }
output "dynamodb_table_arn" { value = local.dynamodb_table_arn }
output "aws_region" { value = var.aws_region }
output "aws_account_id" { value = data.aws_caller_identity.current.account_id }
output "ecr_repository_name" { value = length(aws_ecr_repository.api) > 0 ? aws_ecr_repository.api[0].name : "" }
output "adapter_type" { value = var.adapter_type }
output "project_name" { value = var.project_name }
output "environment" { value = var.environment }
output "apprunner_image_tag" { value = var.apprunner_image_tag }

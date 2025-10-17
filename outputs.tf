output "instructions" {
  description = "Post-deployment instructions (shown when deploy_api=true)."
  value = var.deploy_api ? join("\n", [
    "Infrastructure Initialized Successfully!",
    "",
    "Next Steps:",
    "",
    "1. Define your AWS resources (S3 bucket, DynamoDB table, Lambda function, ECR repo, App Runner service) in separate *.tf files.",
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

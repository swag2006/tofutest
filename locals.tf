locals {
  bucket_name                   = length(aws_s3_bucket.media) > 0 ? aws_s3_bucket.media[0].id : var.existing_s3_bucket_name
  dynamodb_table_name           = length(aws_dynamodb_table.jobs) > 0 ? aws_dynamodb_table.jobs[0].name : var.existing_dynamodb_table_name
  dynamodb_table_arn            = length(aws_dynamodb_table.jobs) > 0 ? aws_dynamodb_table.jobs[0].arn : var.existing_dynamodb_table_arn

  lambda_role_arn               = length(aws_iam_role.lambda_role) > 0 ? aws_iam_role.lambda_role[0].arn : (
    length(data.aws_iam_role.lambda_existing) > 0 ? data.aws_iam_role.lambda_existing[0].arn : ""
  )

  apprunner_role_arn            = length(aws_iam_role.apprunner_role) > 0 ? aws_iam_role.apprunner_role[0].arn : (
    length(data.aws_iam_role.apprunner_existing) > 0 ? data.aws_iam_role.apprunner_existing[0].arn : ""
  )

  apprunner_ecr_access_role_arn = length(aws_iam_role.apprunner_ecr_access) > 0 ? aws_iam_role.apprunner_ecr_access[0].arn : (
    length(data.aws_iam_role.apprunner_ecr_access_existing) > 0 ? data.aws_iam_role.apprunner_ecr_access_existing[0].arn : ""
  )

  ecr_repository_url            = length(aws_ecr_repository.api) > 0 ? aws_ecr_repository.api[0].repository_url : var.existing_ecr_repository_url
}

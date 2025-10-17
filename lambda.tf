# Lambda Function
resource "aws_lambda_function" "processor" {
  function_name = "${var.project_name}-processor-${var.environment}"
  role          = local.lambda_role_arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = var.lambda_timeout_seconds
  memory_size   = var.lambda_memory_mb
  filename      = "lambda_placeholder.zip"
  environment {
    variables = {
      S3_BUCKET_NAME      = local.bucket_name
      DYNAMODB_TABLE_NAME = local.dynamodb_table_name
      ADAPTER_TYPE        = var.adapter_type
      OPENAI_API_KEY      = var.openai_api_key
    }
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]

    precondition {
      condition     = local.lambda_role_arn != ""
      error_message = "Lambda role ARN must be provided (set create_lambda_role=true or supply existing_lambda_role_name)."
    }
    precondition {
      condition     = local.dynamodb_table_name != "" && local.dynamodb_table_arn != ""
      error_message = "DynamoDB table must exist (create_dynamodb_table=true or supply existing_dynamodb_table_name + existing_dynamodb_table_arn)."
    }
    precondition {
      condition     = local.bucket_name != ""
      error_message = "S3 bucket name must be provided (create_s3_bucket=true or supply existing_s3_bucket_name)."
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.processor.function_name}"
  retention_in_days = var.environment == "prod" ? 30 : 7
}

# S3 Event Trigger (only if bucket created)
resource "aws_lambda_permission" "allow_s3" {
  count         = var.create_s3_bucket ? 1 : 0
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.create_s3_bucket ? aws_s3_bucket.media[0].arn : "arn:aws:s3:::${var.existing_s3_bucket_name}"
}

resource "aws_s3_bucket_notification" "media_events" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.media[0].id
  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "media-in/"
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

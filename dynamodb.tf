# DynamoDB Table (conditional)
resource "aws_dynamodb_table" "jobs" {
  count         = var.create_dynamodb_table ? 1 : 0
  name          = "${var.project_name}-jobs-${var.environment}"
  billing_mode  = "PAY_PER_REQUEST"
  hash_key      = "job_id"
  attribute { name = "job_id" type = "S" }
  ttl { attribute_name = "ttl" enabled = true }
  point_in_time_recovery { enabled = var.environment == "prod" }
}


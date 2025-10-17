variable "deploy_api" {
  type        = bool
  description = "Whether to deploy the API components (controls conditional instructions output)."
  default     = true
}

variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Base name prefix for all resources."
  default     = "vehicle-assessment"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, staging, prod)."
  default     = "dev"
  validation {
    condition     = contains(["dev","staging","prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "lambda_timeout_seconds" {
  type        = number
  description = "Lambda function timeout in seconds."
  default     = 30
}

variable "lambda_memory_mb" {
  type        = number
  description = "Lambda function memory size in MB."
  default     = 512
}

variable "adapter_type" {
  type        = string
  description = "Adapter implementation type (e.g. mock, prod)."
  default     = "mock"
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI API key passed to the Lambda/App Runner for AI functionality."
  default     = ""
  sensitive   = true
}

variable "api_cpu" {
  type        = string
  description = "App Runner instance CPU (e.g. '1 vCPU')."
  default     = "1 vCPU"
}

variable "api_memory_mb" {
  type        = string
  description = "App Runner instance memory (e.g. '2 GB')."
  default     = "2 GB"
}

variable "create_s3_bucket" {
  type        = bool
  description = "Whether to create the S3 bucket. Set false to use an existing bucket name."
  default     = true
}

variable "existing_s3_bucket_name" {
  type        = string
  description = "Existing S3 bucket name when create_s3_bucket=false."
  default     = ""
  # Validation removed (cannot reference other variables). Provide value when create_s3_bucket=false.
}

variable "create_lambda_role" {
  type        = bool
  description = "Create Lambda IAM role. Set false to use an existing role name."
  default     = true
}

variable "existing_lambda_role_name" {
  type        = string
  description = "Existing Lambda role name when create_lambda_role=false."
  default     = ""
  # Provide value when create_lambda_role=false.
}

variable "create_apprunner_roles" {
  type        = bool
  description = "Create App Runner service and ECR access roles. Set false to use existing role names."
  default     = true
}

variable "existing_apprunner_role_name" {
  type        = string
  description = "Existing App Runner service role name when create_apprunner_roles=false."
  default     = ""
  # Provide value when create_apprunner_roles=false.
}

variable "existing_apprunner_ecr_access_role_name" {
  type        = string
  description = "Existing App Runner ECR access role name when create_apprunner_roles=false."
  default     = ""
  # Provide value when create_apprunner_roles=false.
}

variable "create_ecr_repo" {
  type        = bool
  description = "Whether to create ECR repository."
  default     = true
}

variable "existing_ecr_repository_url" {
  type        = string
  description = "Existing ECR repository URL when create_ecr_repo=false."
  default     = ""
  # Provide value when create_ecr_repo=false.
}

variable "create_apprunner_service" {
  type        = bool
  description = "Whether to create App Runner service (also requires deploy_api=true)."
  default     = true
}

variable "create_dynamodb_table" {
  type        = bool
  description = "Whether to create the DynamoDB table."
  default     = true
}

variable "existing_dynamodb_table_name" {
  type        = string
  description = "Existing DynamoDB table name when create_dynamodb_table=false."
  default     = ""
  # Provide value when create_dynamodb_table=false.
}

variable "existing_dynamodb_table_arn" {
  type        = string
  description = "Existing DynamoDB table ARN when create_dynamodb_table=false."
  default     = ""
  # Provide value when create_dynamodb_table=false.
}

variable "apprunner_image_tag" {
  type        = string
  description = "Docker image tag for App Runner service (defaults to 'latest')."
  default     = "latest"
}

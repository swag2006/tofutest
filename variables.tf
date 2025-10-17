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
  validation {
    condition     = var.create_s3_bucket || length(var.existing_s3_bucket_name) > 0
    error_message = "existing_s3_bucket_name must be set when create_s3_bucket is false"
  }
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
  validation {
    condition     = var.create_lambda_role || length(var.existing_lambda_role_name) > 0
    error_message = "existing_lambda_role_name must be set when create_lambda_role is false"
  }
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
  validation {
    condition     = var.create_apprunner_roles || length(var.existing_apprunner_role_name) > 0
    error_message = "existing_apprunner_role_name must be set when create_apprunner_roles is false"
  }
}

variable "existing_apprunner_ecr_access_role_name" {
  type        = string
  description = "Existing App Runner ECR access role name when create_apprunner_roles=false."
  default     = ""
  validation {
    condition     = var.create_apprunner_roles || length(var.existing_apprunner_ecr_access_role_name) > 0
    error_message = "existing_apprunner_ecr_access_role_name must be set when create_apprunner_roles is false"
  }
}

variable "create_ecr_repo" {
  type        = bool
  description = "Whether to create ECR repository."
  default     = true
}

variable "existing_ecr_repository_url" {
  type        = string
  description = "Existing ECR repository URL (e.g. account.dkr.ecr.region.amazonaws.com/repo) when create_ecr_repo=false."
  default     = ""
  validation {
    condition     = var.create_ecr_repo || length(var.existing_ecr_repository_url) > 0
    error_message = "existing_ecr_repository_url must be set when create_ecr_repo is false"
  }
}

variable "create_apprunner_service" {
  type        = bool
  description = "Whether to create App Runner service (also requires deploy_api=true)."
  default     = true
}

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

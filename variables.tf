variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "vehicle-assessment"
}

variable "adapter_type" {
  description = "AI adapter type: mock or openai"
  type        = string
  default     = "mock"
  
  validation {
    condition     = contains(["mock", "openai"], var.adapter_type)
    error_message = "adapter_type must be either 'mock' or 'openai'"
  }
}



variable "openai_api_key" {
  description = "OpenAI API key (required if adapter_type=openai)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "lambda_memory_mb" {
  description = "Lambda memory in MB"
  type        = number
  default     = 3008
}

variable "lambda_timeout_seconds" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 900
}

variable "api_cpu" {
  description = "App Runner CPU units (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
}

variable "api_memory_mb" {
  description = "App Runner memory in MB (512, 1024, 2048, 3072, 4096, etc.)"
  type        = number
  default     = 1024
}

variable "deploy_api" {
  description = "Whether to deploy App Runner API service (set to false if ECR is empty)"
  type        = bool
  default     = false
}

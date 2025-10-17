output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.media.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.jobs.name
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.processor.function_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for API container"
  value       = aws_ecr_repository.api.repository_url
}

output "api_url" {
  description = "App Runner service URL (only if deployed)"
  value       = var.deploy_api ? aws_apprunner_service.api[0].service_url : "Not deployed - set deploy_api=true and push container image first"
}

output "api_endpoint" {
  description = "Full API endpoint URL (only if deployed)"
  value       = var.deploy_api ? "https://${aws_apprunner_service.api[0].service_url}" : "Not deployed - set deploy_api=true and push container image first"
}

output "instructions" {
  description = "Next steps to deploy"
  value       = var.deploy_api ? <<-EOT
    
    ✅ Infrastructure Created Successfully!
    
    📦 S3 Bucket: ${aws_s3_bucket.media.id}
    📊 DynamoDB Table: ${aws_dynamodb_table.jobs.name}
    ⚡ Lambda Function: ${aws_lambda_function.processor.function_name}
    🐳 ECR Repository: ${aws_ecr_repository.api.repository_url}
    🌐 API URL: https://${aws_apprunner_service.api[0].service_url}
    
    Next Steps:
    
    1. Deploy Lambda function:
       cd ~/leasepro-rag/lambda
       pip3 install -r requirements.txt -t build/ --quiet
       cp *.py build/ && cp -r processors adapters renderers utils build/
       cd build && zip -r ../deployment.zip . -q && cd ..
       aws lambda update-function-code --function-name ${aws_lambda_function.processor.function_name} --zip-file fileb://deployment.zip
    
    2. Test the API:
       curl https://${aws_apprunner_service.api[0].service_url}/health
    
  EOT
  : <<-EOT
    
    ✅ Infrastructure Created Successfully!
    
    📦 S3 Bucket: ${aws_s3_bucket.media.id}
    📊 DynamoDB Table: ${aws_dynamodb_table.jobs.name}
    ⚡ Lambda Function: ${aws_lambda_function.processor.function_name}
    🐳 ECR Repository: ${aws_ecr_repository.api.repository_url}
    
    Next Steps:
    
    1. Deploy Lambda function:
       cd ~/leasepro-rag/lambda
       pip3 install -r requirements.txt -t build/ --quiet
       cp *.py build/ && cp -r processors adapters renderers utils build/
       cd build && zip -r ../deployment.zip . -q && cd ..
       aws lambda update-function-code --function-name ${aws_lambda_function.processor.function_name} --zip-file fileb://deployment.zip
    
    2. Build and push API container (from local machine with Docker):
       cd ~/leasepro-rag/api
       aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.api.repository_url}
       docker build -t ${aws_ecr_repository.api.repository_url}:latest .
       docker push ${aws_ecr_repository.api.repository_url}:latest
    
    3. After pushing container, enable App Runner:
       cd ~/leasepro-rag/terraform
       echo 'deploy_api = true' >> terraform.tfvars
       tofu apply -auto-approve
    
  EOT
}

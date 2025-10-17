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

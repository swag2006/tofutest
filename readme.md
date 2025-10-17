```shell
git clone https://github.com/swag2006/tofutest.git
cd tofutest

# (Optional) create a tfvars file to override defaults
cat > dev.auto.tfvars <<'EOF'
aws_region = "us-east-1"
deploy_api = true
EOF

# Initialize (downloads providers & sets up backend)
tofu init

# Review the execution plan
tofu plan

# Apply infrastructure
tofu apply -auto-approve

# Show post-deployment instructions output (if deploy_api=true)
tofu output instructions
```

Variables:
- deploy_api (bool): Controls whether instruction output is populated. Default: true.
- aws_region (string): AWS region for resources. Default: us-east-1.

Next Steps:
1. Add resource files (e.g., s3.tf, dynamodb.tf, lambda.tf, ecr.tf, apprunner.tf) defining actual AWS resources.
2. Update output in `outputs.tf` to reference real resource attributes once created.
3. Re-run `tofu plan` and `tofu apply` to deploy new resources.

Tips:
- Use `tofu fmt` to format code.
- Use `tofu validate` for static validation before planning.
- Keep `.terraform.lock.hcl` committed for provider version pinning.

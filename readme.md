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

Additional Variables (conditional creation):
- create_s3_bucket (bool, default true)
- existing_s3_bucket_name (string) when create_s3_bucket=false
- create_lambda_role (bool, default true)
- existing_lambda_role_name (string) when create_lambda_role=false
- create_apprunner_roles (bool, default true)
- existing_apprunner_role_name (string) when create_apprunner_roles=false
- existing_apprunner_ecr_access_role_name (string) when create_apprunner_roles=false
- create_ecr_repo (bool, default true)
- create_apprunner_service (bool, default true; requires deploy_api=true)
- existing_ecr_repository_url (string) when create_ecr_repo=false

Using existing resources instead of creating new ones:
1. Set the corresponding create_* variable to false.
2. Provide the existing_* name variable.
3. Run: `tofu plan` to confirm no create attempts for those resources.

Example dev.auto.tfvars snippet for existing bucket & roles:
```hcl
create_s3_bucket = false
existing_s3_bucket_name = "vehicle-assessment-dev-082608134871"
create_lambda_role = false
existing_lambda_role_name = "vehicle-assessment-lambda-dev"
create_apprunner_roles = false
existing_apprunner_role_name = "vehicle-assessment-apprunner-dev"
existing_apprunner_ecr_access_role_name = "vehicle-assessment-apprunner-ecr-dev"
```

Importing existing resources (alternative to flags):
If you prefer to keep create_* = true and adopt into state, import before apply:
```shell
tofu import aws_s3_bucket.media[0] vehicle-assessment-dev-082608134871
tofu import aws_iam_role.lambda_role[0] vehicle-assessment-lambda-dev
tofu import aws_iam_role.apprunner_role[0] vehicle-assessment-apprunner-dev
tofu import aws_iam_role.apprunner_ecr_access[0] vehicle-assessment-apprunner-ecr-dev
```
(Adjust names to match the actual existing resources.)

Outputs of interest:
```shell
tofu output bucket_name
tofu output lambda_role_name
tofu output apprunner_service_url
```

Next Steps:
1. Add resource files (e.g., s3.tf, dynamodb.tf, lambda.tf, ecr.tf, apprunner.tf) defining actual AWS resources.
2. Update output in `outputs.tf` to reference real resource attributes once created.
3. Re-run `tofu plan` and `tofu apply` to deploy new resources.

Tips:
- Use `tofu fmt` to format code.
- Use `tofu validate` for static validation before planning.
- Keep `.terraform.lock.hcl` committed for provider version pinning.

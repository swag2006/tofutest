```markdown
# Quick Start
```shell
git clone https://github.com/swag2006/tofutest.git
cd tofutest

# (Optional) variable overrides
cat > dev.auto.tfvars <<'EOF'
aws_region = "us-east-1"
deploy_api = true
apprunner_image_tag = "latest"
EOF

# Create placeholder lambda zip (first deploy)
chmod +x scripts/create_placeholder_lambda_zip.sh
scripts/create_placeholder_lambda_zip.sh

# Init & deploy
tofu init
tofu plan
tofu apply -auto-approve

# Outputs
tofu output bucket_name
tofu output dynamodb_table_name
tofu output lambda_function_name
```

## Build & Push API Image (ECR + App Runner)
```shell
chmod +x scripts/build_push_ecr.sh
scripts/build_push_ecr.sh $(tofu output -raw ecr_repository_url) $(tofu output -raw apprunner_image_tag) api
# Update image tag variable if you pushed a new tag
```

## Update Lambda Code
```shell
chmod +x scripts/deploy_lambda.sh
scripts/deploy_lambda.sh $(tofu output -raw lambda_function_name) lambda_src
```

## Key Outputs
- bucket_name
- dynamodb_table_name / dynamodb_table_arn
- lambda_function_name
- ecr_repository_url / ecr_repository_name
- apprunner_service_url
- aws_account_id / aws_region

## Variables (Core)
- project_name, environment, aws_region, deploy_api
- adapter_type, openai_api_key (sensitive)
- lambda_timeout_seconds, lambda_memory_mb
- api_cpu, api_memory_mb, apprunner_image_tag

## Conditional Creation Flags
create_s3_bucket, create_dynamodb_table, create_lambda_role, create_apprunner_roles, create_ecr_repo, create_apprunner_service
Provide existing_* vars when flag is false.

## Existing Resource Imports (alternative)
```shell
tofu import aws_s3_bucket.media[0] <bucket>
tofu import aws_iam_role.lambda_role[0] <lambda_role>
tofu import aws_iam_role.apprunner_role[0] <apprunner_role>
```

## Directory Layout
- api/ (FastAPI container for App Runner)
- lambda_src/ (Lambda placeholder code)
- scripts/ (deployment helpers)
- *.tf modular files (per component)

## Next Steps
- Add remote state backend
- Add alarms/monitoring
- Harden IAM policies further
- Add automated CI (fmt, validate, plan) pipeline

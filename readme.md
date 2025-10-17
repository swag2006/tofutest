# Infrastructure Overview
A modular OpenTofu/Terraform setup provisioning: S3 (media), DynamoDB (jobs), Lambda (processor), ECR + App Runner (API), with conditional creation flags to reuse existing resources.

## Prerequisites
- AWS CLI configured with credentials
- OpenTofu/Terraform >= 1.6
- Docker (for ECR/App Runner image)
- Python 3.11 (for Lambda packaging)

## Quick Start
```shell
git clone https://github.com/swag2006/tofutest.git
cd tofutest

# (Optional) variable overrides
cat > dev.auto.tfvars <<'EOF'
aws_region = "us-east-2"
deploy_api = true
apprunner_image_tag = "latest"
EOF

# Create placeholder lambda zip (first deploy)
chmod +x scripts/create_placeholder_lambda_zip.sh
scripts/create_placeholder_lambda_zip.sh

# Init & deploy
tofu fmt
tofu init
tofu validate
tofu plan
tofu apply -auto-approve

# Inspect outputs
tofu output bucket_name
tofu output dynamodb_table_name
tofu output lambda_function_name
```

## Build & Push API Image (ECR + App Runner)
```shell
chmod +x scripts/build_push_ecr.sh
scripts/build_push_ecr.sh $(tofu output -raw ecr_repository_url) $(tofu output -raw apprunner_image_tag) api
```
Update `apprunner_image_tag` variable (tfvars) when pushing a new tag; re-apply to trigger a redeploy.

## Update Lambda Code
```shell
chmod +x scripts/deploy_lambda.sh
scripts/deploy_lambda.sh $(tofu output -raw lambda_function_name) lambda_src
```

## Key Outputs
- project_name, environment
- aws_account_id, aws_region
- bucket_name
- dynamodb_table_name / dynamodb_table_arn
- lambda_function_name, lambda_role_name
- ecr_repository_url / ecr_repository_name, apprunner_image_tag
- apprunner_service_url
- adapter_type

## Core Variables
project_name, environment, aws_region, deploy_api
lambda_timeout_seconds, lambda_memory_mb
api_cpu, api_memory_mb, apprunner_image_tag
adapter_type, openai_api_key (sensitive)

## Conditional Creation Flags
create_s3_bucket, create_dynamodb_table,
create_lambda_role, create_apprunner_roles,
create_ecr_repo, create_apprunner_service

Provide the matching existing_* variable when a create_* flag is false:
- existing_s3_bucket_name
- existing_dynamodb_table_name / existing_dynamodb_table_arn
- existing_lambda_role_name
- existing_apprunner_role_name / existing_apprunner_ecr_access_role_name
- existing_ecr_repository_url

### Preconditions
Resource preconditions will fail `plan/apply` early if you disable creation but omit required existing_* values.

## Reusing Existing Resources (alternative: import)
If you keep create_* = true and want to adopt existing resources:
```shell
tofu import aws_s3_bucket.media[0] <bucket>
tofu import aws_iam_role.lambda_role[0] <lambda_role>
tofu import aws_iam_role.apprunner_role[0] <apprunner_role>
```
(Adjust resource addresses if counts differ.)

## Directory Layout
- api/ (FastAPI App Runner container)
- lambda_src/ (Lambda placeholder code)
- scripts/ (deployment helpers)
- *.tf (modular infrastructure components)

## Deployment Flow Summary
1. Prepare tfvars (optionally set create_* flags).
2. Generate placeholder Lambda zip.
3. `tofu init`, `tofu plan`, fix any precondition errors.
4. `tofu apply`.
5. Build & push ECR image; adjust `apprunner_image_tag`; re-apply if needed.
6. Deploy updated Lambda code via script.

## Security Notes
- Do not commit secrets. Pass `-var 'openai_api_key=***'` or use environment variable with TF Cloud variable sets.
- IAM policies restrict access to specific bucket and DynamoDB table ARNs.

## Next Steps / Enhancements
- Remote state (S3 backend + DynamoDB lock)
- CloudWatch alarms & dashboards
- CI pipeline (fmt, validate, plan comment)
- Unit tests for Lambda code
- Add tagging strategy for cost allocation

## Troubleshooting
- Missing existing_* values: precondition error explains which value to add.
- App Runner image not found: ensure ECR push succeeded and `apprunner_image_tag` matches.
- 409 conflicts: set create_* flag false and supply existing_* name or import resource.

## License
Internal hackathon project (adjust as needed).

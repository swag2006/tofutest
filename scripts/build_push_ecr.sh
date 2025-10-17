#!/usr/bin/env bash
set -euo pipefail

REPO_URL="$1" # e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/vehicle-assessment-api-dev
IMAGE_TAG="${2:-latest}"
DOCKERFILE_DIR="${3:-api}"

if [[ -z "$REPO_URL" ]]; then
  echo "Usage: $0 <ecr_repository_url> [image_tag] [dockerfile_dir]" >&2
  exit 1
fi

if [[ ! -d "$DOCKERFILE_DIR" ]]; then
  echo "Dockerfile directory '$DOCKERFILE_DIR' not found" >&2
  exit 1
fi

AWS_REGION="${AWS_REGION:-$(tofu output -raw aws_region 2>/dev/null || echo us-east-1)}"
#!/usr/bin/env bash
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${REPO_URL%%/*}"

docker build -t "$REPO_URL:$IMAGE_TAG" "$DOCKERFILE_DIR"
docker push "$REPO_URL:$IMAGE_TAG"

echo "Image pushed: $REPO_URL:$IMAGE_TAG"
set -euo pipefail

ZIP="lambda_placeholder.zip"
SRC_DIR="lambda_src"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Directory '$SRC_DIR' not found" >&2
  exit 1
fi

rm -f "$ZIP"
zip -q "$ZIP" "$SRC_DIR"/*.py || true

echo "Created $ZIP for initial Terraform apply."

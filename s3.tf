# S3 Bucket (conditional)
resource "aws_s3_bucket" "media" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "media" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.media[0].id
  versioning_configuration { status = "Disabled" }
}

resource "aws_s3_bucket_cors_configuration" "media" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.media[0].id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "media" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.media[0].id
  rule {
    id     = "expire-old-results"
    status = "Enabled"
    filter { prefix = "results/" }
    expiration { days = 30 }
  }
}


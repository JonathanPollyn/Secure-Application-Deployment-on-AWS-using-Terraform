resource "aws_s3_bucket" "app_assets" {
  bucket = "secure-prod-style-app-assets-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "secure-prod-style-app-assets"
    Environment = "dev"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Simple policy: enforce TLS and deny anonymous/public access
data "aws_iam_policy_document" "app_assets_policy" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.app_assets.arn,
      "${aws_s3_bucket.app_assets.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid     = "DenyAnonymousAccess"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.app_assets.arn,
      "${aws_s3_bucket.app_assets.arn}/*"
    ]

    # Deny requests that are not signed (anonymous/public).
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["Anonymous"]
    }
  }
}

resource "aws_s3_bucket_policy" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  policy = data.aws_iam_policy_document.app_assets_policy.json
}
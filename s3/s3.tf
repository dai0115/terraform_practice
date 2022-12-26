# プライベートバケットの作成
resource "aws_s3_bucket" "private" {
  bucket = "private-${var.bucket_name_suffix}"
}

# プライベートバケットのバージョニング設定
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.private.id
  versioning_configuration {
    status = "Enabled"
  }
}

# プライベートバケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.private.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# プライベートバケットなのでパブリック・アクセスをブロックする
resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# パブリックバケット
resource "aws_s3_bucket" "public" {
  bucket = "public-${var.bucket_name_suffix}"
}

# パブリックバケットのACL設定
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.public.id
  acl    = "public-read"
}

# パブリックバケットのcorsルールの設定
resource "aws_s3_bucket_cors_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = [ "*" ]
    max_age_seconds = 3000
  }
}

# アクセスログ用のバケット
resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-${var.bucket_name_suffix}"
}

# アクセスログ用のバケットのライフサイクルポリシー
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id = "lifecycle-rule1"
    status = "Enabled"
    expiration {
        days = 30
    }
  }
}

# 書き込みのためのバケットポリシー
data "aws_iam_policy_document" "alb_log" {
    statement {
      effect = "Allow"
      actions = ["s3:PutObject"]
      resources = [
        "arn:aws:s3:::${aws_s3_bucket.alb_log.id}",
        "arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"
        ]
      principals {
        type = "AWS"
        identifiers = ["582318560864"]
      }
    }
}

 # バケットとバケットポリシーの関連付け
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}
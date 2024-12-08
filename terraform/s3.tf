resource "aws_s3_bucket" "file_bucket" {
  bucket = var.bucket_name

  lifecycle {
    ignore_changes = [bucket]
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_policy" "file_bucket_policy" {
  bucket = aws_s3_bucket.file_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.file_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "file_bucket_lifecycle" {
  bucket = aws_s3_bucket.file_bucket.id

  rule {
    id     = "expire-objects"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.file_bucket.id
  key    = "lambda/arquivolambda.zip"
  source = "${path.module}/arquivolambda.zip"
  acl    = "private"
}



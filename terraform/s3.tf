resource "aws_s3_bucket" "file_bucket" {
  bucket = "ada-contabilidade-storage-${random_id.bucket_suffix.hex}"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [bucket]
  }

  tags = {
    Name        = "ada-contabilidade-storage-${random_id.bucket_suffix.hex}"
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
  source = "/home/achilles/Área de Trabalho/projeto-final-ada/app/arquivolambda.zip"
}
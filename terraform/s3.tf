# s3.tf

resource "aws_s3_bucket" "file_bucket" {
  bucket = "ada-contabilidade-storage-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "ada-contabilidade-storage"
    Environment = "Production"
  }

  lifecycle {
    ignore_changes  = [bucket]
  }
}

resource "aws_s3_bucket_acl" "file_bucket_acl" {
  bucket = aws_s3_bucket.file_bucket.bucket
  acl    = "private"
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.file_bucket.id
  key    = "lambda/arquivolambda.zip"
  source = "/home/runner/work/projeto-final-ada/projeto-final-ada/app/arquivolambda.zip"
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
resource "aws_s3_bucket" "file_bucket" {
  bucket = var.bucket_name

  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "file_bucket_lifecycle" {
  bucket = aws_s3_bucket.file_bucket.bucket

  rule {
    id     = "expire-objects"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.file_bucket.bucket
  key    = "lambda/arquivolambda.zip"
  source = "/home/achilles/Área de Trabalho/projeto-final-ada/app/arquivolambda.zip"
}
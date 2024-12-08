
resource "aws_s3_bucket" "file_bucket" {
  bucket = var.bucket_name
  # object_lock_configuration block removed due to deprecation

  lifecycle {
    ignore_changes = [bucket]
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
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
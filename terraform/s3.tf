resource "aws_s3_bucket" "file_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.file_bucket.bucket
  key    = "lambda/package.zip"
  source = "./app/fileProcessor.zip"
}
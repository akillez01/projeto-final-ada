resource "aws_s3_bucket" "file_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.file_bucket.bucket
  key    = "lambda/arquivolambda.zip"
  source = "/home/achilles/Área de Trabalho/projeto-final-ada/app/arquivolambda.zip"
}
resource "aws_lambda_function" "file_processor" {
  function_name = "fileProcessor"
  s3_bucket     = aws_s3_bucket.file_bucket.bucket
  s3_key        = "lambda/package.zip"  # Nome do arquivo no S3
  handler       = "index.handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_role.arn
}

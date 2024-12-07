resource "aws_lambda_function" "arquivolambda" {
  function_name = "arquivolambda"
  s3_bucket     = aws_s3_bucket.file_bucket.bucket
  s3_key        = "lambda/arquivolambda.zip"  # Nome do arquivo no S3
  handler       = "index.handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_role.arn

  depends_on = [aws_s3_object.lambda_code]
}
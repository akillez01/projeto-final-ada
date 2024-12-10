resource "aws_lambda_function" "arquivolambda" {
  function_name = "arquivolambda"
  s3_bucket     = aws_s3_bucket.file_bucket.id  # Aponta para o bucket S3 onde o arquivo está
  s3_key        = aws_s3_object.lambda_code.key  # Chave do arquivo ZIP no bucket S3
  handler       = "index.handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  memory_size   = 256

  depends_on = [aws_s3_object.lambda_code]  # Garante que o arquivo esteja no S3 antes de criar a Lambda
}

# IAM Role para a Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

# Política associada ao Role da Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket"]
        # Recursos de acesso ao S3 (bucket e objetos dentro dele)
        Resource = [
          aws_s3_bucket.file_bucket.arn,                # Acesso ao bucket
          "${aws_s3_bucket.file_bucket.arn}/*"          # Acesso aos objetos dentro do bucket
        ]
        Effect = "Allow"
      },
      {
        Action = "sqs:ReceiveMessage"
        # Permissão para acessar a fila SQS
        Resource = aws_sqs_queue.file_processing_queue.arn
        Effect = "Allow"
      },
      {
        Action = "sns:Publish"
        # Permissão para publicar mensagens no SNS
        Resource = aws_sns_topic.file_uploaded_topic.arn
        Effect = "Allow"
      },
      {
        Action = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"]
        # Permissão para acessar a tabela DynamoDB
        Resource = aws_dynamodb_table.file_metadata_table.arn
        Effect = "Allow"
      }
    ]
  })
}
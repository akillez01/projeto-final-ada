# IAM Role para a Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
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
        # Permissões para acessar o bucket S3 e os objetos dentro dele
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.file_bucket.arn,                # Acesso ao bucket
          "${aws_s3_bucket.file_bucket.arn}/*"          # Acesso aos objetos dentro do bucket
        ]
        Effect = "Allow"
      },
      {
        # Permissões para acessar a fila SQS
        Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.file_processing_queue.arn
        Effect = "Allow"
      },
      {
        # Permissões para publicar mensagens no SNS
        Action = "sns:Publish"
        Resource = aws_sns_topic.file_uploaded_topic.arn
        Effect = "Allow"
      },
      {
        # Permissões para acessar a tabela DynamoDB
        Action = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"]
        Resource = aws_dynamodb_table.file_metadata_table.arn
        Effect = "Allow"
      },
      {
        # Permissões básicas para executar a Lambda
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
        Effect = "Allow"
      }
    ]
  })
}

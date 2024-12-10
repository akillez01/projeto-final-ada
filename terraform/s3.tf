resource "aws_s3_bucket" "file_bucket" {
  bucket = "ada-contabilidade-storage"  # Nome fixo para o bucket

  tags = {
    Name        = "ada-contabilidade-storage"
    Environment = "Production"
  }

  lifecycle {
    # Remover ou setar prevent_destroy como false
    prevent_destroy = false
  }
}



# Recurso de ACL para o bucket
resource "aws_s3_bucket_acl" "file_bucket_acl" {
  bucket = aws_s3_bucket.file_bucket.bucket
  acl    = "private"
}

# Recurso para o arquivo no S3
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.file_bucket.id
  key    = "lambda/arquivolambda.zip"
  source = "/home/runner/work/projeto-final-ada/projeto-final-ada/app/arquivolambda.zip"
}

# Política para o bucket
resource "aws_s3_bucket_policy" "file_bucket_policy" {
  bucket = aws_s3_bucket.file_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.file_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket" "file_bucket" {
  bucket = var.bucket_name

  # Adiciona uma regra de ciclo de vida para esvaziar o bucket antes de excluir
  lifecycle_rule {
    enabled = true
    prefix  = "/"

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
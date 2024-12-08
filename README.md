# Projeto Final ADA - Automação de Infraestrutura com Terraform e GitHub Actions

Este projeto demonstra como automatizar a criação e destruição de infraestrutura na AWS usando Terraform e GitHub Actions.

## Estrutura do Projeto

- `terraform/`: Contém os arquivos de configuração do Terraform.
  - `main.tf`: Arquivo principal do Terraform.
  - `variables.tf`: Definição das variáveis do Terraform.
  - `s3.tf`: Configuração do bucket S3.
  - `dynamodb.tf`: Configuração da tabela DynamoDB.
  - `iam_role.tf`: Configuração do IAM Role e políticas associadas.
- `app/`: Contém o código da aplicação.
  - `upload_zip.py`: Script para criar e enviar o arquivo ZIP para o S3.
  - `requirements.txt`: Dependências da aplicação.
- `.github/workflows/`: Contém os arquivos de workflow do GitHub Actions.
  - `apply.yml`: Workflow para aplicar a infraestrutura.
  - `destroy.yml`: Workflow para destruir a infraestrutura.

## Configuração do Terraform

### Arquivo `variables.tf`

Define as variáveis usadas no Terraform.

```hcl
variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "db_username" {
  description = "Usuário do banco de dados RDS"
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados RDS"
  type        = string
  sensitive   = true
}

Arquivo s3.tf
Configura o bucket S3 e a política de ciclo de vida.

resource "aws_s3_bucket" "file_bucket" {
  bucket = var.bucket_name

  lifecycle {
    ignore_changes = [bucket]
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

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.file_bucket.bucket
  key    = "lambda/arquivolambda.zip"
  source = "/home/achilles/Área de Trabalho/projeto-final-ada/app/arquivolambda.zip"
}

Arquivo dynamodb.tf
Configura a tabela DynamoDB.

resource "aws_dynamodb_table" "file_metadata_table" {
  name           = "file_metadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "file_id"

  attribute {
    name = "file_id"
    type = "S"
  }

  lifecycle {
    ignore_changes = [name]
  }
}

Arquivo iam_role.tf
Configura o IAM Role e as políticas associadas.

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

  lifecycle {
    create_before_destroy = true
    ignore_changes = [name]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.file_bucket.arn,
          "${aws_s3_bucket.file_bucket.arn}/*"
        ]
        Effect = "Allow"
      },
      {
        Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.file_processing_queue.arn
        Effect = "Allow"
      },
      {
        Action = "sns:Publish"
        Resource = aws_sns_topic.file_uploaded_topic.arn
        Effect = "Allow"
      },
      {
        Action = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"]
        Resource = aws_dynamodb_table.file_metadata_table.arn
        Effect = "Allow"
      },
      {
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

Configuração do GitHub Actions
Arquivo apply.yml
Workflow para aplicar a infraestrutura.

name: Apply Infrastructure

on:
  push:
    branches:
      - main
      - producao
      - teste
  pull_request:
    branches:
      - main
      - producao
      - teste

jobs:
  terraform:
    name: 'Terraform Apply'
    runs-on: ubuntu-latest

    steps:
      - name: 'Checkout repository'
        uses: actions/checkout@v2

      - name: 'Set up Python'
        uses: actions/setup-python@v2
        with:
          python-version: 3.8

      - name: 'Install dependencies'
        working-directory: ./app
        run: pip install -r requirements.txt

      - name: 'Create ZIP file'
        working-directory: ./app
        run: python upload_zip.py

      - name: 'Set up Terraform'
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.11

      - name: 'Configure AWS Credentials'
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: 'Terraform Init'
        working-directory: ./terraform
        run: terraform init

      - name: 'Terraform Apply'
        working-directory: ./terraform
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_aws_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          TF_VAR_aws_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_aws_region: "us-east-1"
          TF_VAR_db_username: ${{ secrets.TF_VAR_db_username }}
          TF_VAR_db_password: ${{ secrets.TF_VAR_db_password }}
        run: terraform apply -auto-approve

Arquivo destroy.yml
Workflow para destruir a infraestrutura.

name: Destroy Infrastructure

on:
  push:
    branches:
      - destroy

jobs:
  terraform:
    name: 'Terraform Destroy'
    runs-on: ubuntu-latest

    steps:
      - name: 'Checkout repository'
        uses: actions/checkout@v2

      - name: 'Set up Terraform'
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.11

      - name: 'Configure AWS Credentials'
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: 'Terraform Init'
        working-directory: ./terraform
        run: terraform init

      - name: 'Terraform Destroy'
        working-directory: ./terraform
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_aws_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          TF_VAR_aws_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_aws_region: "us-east-1"
          TF_VAR_db_username: ${{ secrets.TF_VAR_db_username }}
          TF_VAR_db_password: ${{ secrets.TF_VAR_db_password }}
        run: terraform destroy -auto-approve



        Configuração dos Segredos no GitHub
Certifique-se de que os seguintes segredos estão configurados no GitHub:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
TF_VAR_db_username
TF_VAR_db_password
Passos para Aplicar a Infraestrutura
Faça o Commit e Push das Mudanças:

git add .
git commit -m "Configuração inicial do Terraform e GitHub Actions"
git push origin main

Verifique a Execução do Workflow:
Acesse a aba "Actions" no repositório do GitHub e verifique a execução do workflow apply.yml.

Passos para Destruir a Infraestrutura
Crie a Branch destroy e Faça um Push:

git checkout -b destroy
git push origin destroy

Verifique a Execução do Workflow:
Acesse a aba "Actions" no repositório do GitHub e verifique a execução do workflow destroy.yml.

Conclusão
Este projeto demonstra como automatizar a criação e destruição de infraestrutura na AWS usando Terraform e GitHub Actions. Siga os passos descritos neste README para configurar e gerenciar sua infraestrutura de forma eficiente.


Este README fornece uma visão geral completa do projeto, incluindo a configuração do Terraform, GitHub Actions e os passos para aplicar e destruir a infraestrutura.

#
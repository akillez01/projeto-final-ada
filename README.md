# Projeto Final ADA - Automação de Infraestrutura com Terraform e GitHub Actions

Este projeto demonstra como automatizar a criação e destruição de infraestrutura na AWS usando Terraform e GitHub Actions.

## Estrutura do Projeto

- `terraform/`: Contém os arquivos de configuração do Terraform.
  - `main.tf`: Arquivo principal do Terraform.
  - `variables.tf`: Definição das variáveis do Terraform.
  - `s3.tf`: Configuração do bucket S3.
  - `rds.tf`: Configuração da instância RDS.
  - `iam_role.tf`: Configuração do IAM Role e políticas associadas.
  - `security_group.tf`: Configuração do Security Group.
- `app/`: Contém o código da aplicação.
  - `upload_zip.py`: Script para criar e enviar o arquivo ZIP para o S3.
  - `requirements.txt`: Dependências da aplicação.
- `.github/workflows/`: Contém os arquivos de workflow do GitHub Actions.
  - `apply.yml`: Workflow para aplicar a infraestrutura.
  - `destroy.yml`: Workflow para destruir a infraestrutura.

## Configuração do Projeto

### 1. Configuração do Terraform

#### Arquivo `s3.tf`

```hcl
resource "aws_s3_bucket" "file_bucket" {
  bucket = "ada-contabilidade-storage-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "ada-contabilidade-storage"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_acl" "file_bucket_acl" {
  bucket = aws_s3_bucket.file_bucket.bucket
  acl    = "private"
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.file_bucket.id
  key    = "lambda/arquivolambda.zip"
  source = "/home/runner/work/projeto-final-ada/projeto-final-ada/app/arquivolambda.zip"
}

resource "aws_s3_bucket_policy" "file_bucket_policy" {
  bucket = aws_s3_bucket.file_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.file_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.23"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.default.id]
  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = {
    Name = "mydb"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main_subnet_group"
  subnet_ids = [aws_subnet.main_a.id, aws_subnet.main_b.id]

  tags = {
    Name = "main_subnet_group"
  }
}

resource "aws_subnet" "main_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "main_subnet_a"
  }
}

resource "aws_subnet" "main_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "main_subnet_b"
  }
}

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

      - name: 'Configure AWS Credentials'
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: 'Install dependencies'
        working-directory: ./app
        run: pip install -r requirements.txt

      - name: 'Create ZIP file'
        working-directory: ./app
        run: python upload.py

      - name: 'Set up Terraform'
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.11

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
          TF_VAR_db_username: ${{ secrets.DB_USERNAME }}
          TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
          TF_VAR_bucket_name: "ada-contabilidade-storage-${random_id.bucket_suffix.hex}"
          TF_VAR_vpc_id: ${{ secrets.VPC_ID }}
        run: terraform apply -auto-approve

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

      - name: 'Configure AWS Credentials'
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: 'Set up Terraform'
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.11

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
          TF_VAR_db_username: ${{ secrets.DB_USERNAME }}
          TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
          TF_VAR_bucket_name: "ada-contabilidade-storage-${random_id.bucket_suffix.hex}"
          TF_VAR_vpc_id: ${{ secrets.VPC_ID }}
        run: terraform destroy -auto-approve

        3. Resolução de Conflitos de Mesclagem
Para resolver conflitos de mesclagem, siga estes passos:

Navegue até o diretório raiz do seu repositório:

Abra os arquivos com conflitos e resolva-os:

.github/workflows/destroy.yml
terraform/variables.tf
Edite os arquivos para resolver os conflitos. Os conflitos serão marcados com linhas como estas:

Escolha qual código manter ou combine as mudanças conforme necessário. Remova as linhas de marcação de conflito (<<<<<<<, =======, >>>>>>>).

Adicione os arquivos resolvidos:

Finalize a mesclagem:

4. Fluxo de Trabalho
Desenvolvimento:

Faça alterações no código e nos arquivos de configuração do Terraform.
Crie um pull request para a branch main.
Aplicação da Infraestrutura:

Quando o pull request for mesclado na branch main, o workflow apply.yml será acionado.
O Terraform aplicará as mudanças na infraestrutura na AWS.
Destruição da Infraestrutura:

Para destruir a infraestrutura, faça um push para a branch destroy.
O workflow destroy.yml será acionado e o Terraform destruirá a infraestrutura na AWS.
Contribuição
Sinta-se à vontade para contribuir com este projeto. Abra um pull request com suas mudanças e nós as revisaremos o mais rápido possível.

Licença
Este projeto está licenciado sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

Este `README.md` inclui todas as etapas que realizamos, bem como a estrutura do projeto e instruções detalhadas sobre como configurar e usar o projeto.Este `README.md` inclui todas as etapas que realizamos, bem como a estrutura do projeto e instruções detalhadas sobre como configurar e usar o projeto.
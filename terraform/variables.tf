# Variáveis para as credenciais da AWS
variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
  sensitive   = true
}

# Variáveis para o Bucket S3
variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
  default     = "ada-contabilidade-storage"
}

# Variáveis para outros recursos
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "db_adacontab" {
  description = "Nome do banco de dados RDS"
  type        = string
  default     = "file_metadata"
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

variable "vpc_id" {
  description = "ID do VPC"
  type        = string
}


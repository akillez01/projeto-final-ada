# Variáveis para as credenciais da AWS
variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
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
  default     = "mydb"
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

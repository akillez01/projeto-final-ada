variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
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
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

terraform {
  backend "s3" {
    bucket = "ada-contabilidade-storage"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"  # ou a região onde o bucket está localizado
  }
}

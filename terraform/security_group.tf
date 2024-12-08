# Busca a VPC padrão da conta
data "aws_vpc" "default" {
  default = true
}

# Criação do Security Group
resource "aws_security_group" "default" {
  name        = "default_security_group"
  description = "Default security group"
  vpc_id      = data.aws_vpc.default.id # Usando a VPC padrão

  # Regras de entrada (Ingress)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite acesso de qualquer IP (recomendado verificar se é adequado)
  }

  # Regras de saída (Egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Permite todo tipo de tráfego de saída
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags para identificação
  tags = {
    Name = "default_security_group"
  }
}

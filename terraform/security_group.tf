resource "aws_security_group" "default" {
  name        = "default_security_group"
  description = "Default security group"
  vpc_id      = var.vpc_id

  lifecycle {
    ignore_changes = [name]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default_security_group"
  }
}
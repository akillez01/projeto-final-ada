# security_group.tf

resource "aws_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "default_security_group"
  }
}
resource "aws_db_instance" "contab" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.db_adacontab
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true


  # Habilita monitoramento básico
  monitoring_interval = 0

  tags = {
    Name    = "RDS Contabil"
    Projeto = "Ada Contabilidade"
    dono    = "Achilles"
  }
}


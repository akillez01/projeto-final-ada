resource "aws_dynamodb_table" "file_metadata_table" {
  name           = "file_metadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "file_metadata"
  }

  lifecycle {
    ignore_changes = [name]
  }
}
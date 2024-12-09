# dynamodb.tf

resource "aws_dynamodb_table" "file_metadata_table" {
  name           = "file_metadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "file_id"

  attribute {
    name = "file_id"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name]
  }
}
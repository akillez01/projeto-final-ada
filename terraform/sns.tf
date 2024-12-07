# SNS Topic
resource "aws_sns_topic" "file_uploaded_topic" {
  name = "file-uploaded-topic"
}
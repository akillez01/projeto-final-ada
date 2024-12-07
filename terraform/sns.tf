# SNS Topic
resource "aws_sns_topic" "arquivo_uploaded_topic" {
  name = "arquivo-uploaded-topic"
}
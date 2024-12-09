
# SNS Subscription for Email
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.file_uploaded_topic.arn
  protocol  = "email"
  endpoint  = "achilles.oliveira.souza@gmail.com"
}
# SNS Subscription for SQS
resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.file_uploaded_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.file_processing_queue.arn
}

# SNS Subscription for Email
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.file_uploaded_topic.arn
  protocol  = "email"
  endpoint  = "achilles.oliveira.souza@gmail.com"
}

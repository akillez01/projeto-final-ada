# SQS Queue
resource "aws_sqs_queue" "arquivo_processing_queue" {
  name = "arquivo-processing-queue"
}
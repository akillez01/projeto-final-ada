# SQS Queue
resource "aws_sqs_queue" "file_processing_queue" {
  name = "file-processing-queue"
  visibility_timeout_seconds = 60
}
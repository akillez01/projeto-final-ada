output "bucket_name" {
  value = aws_s3_bucket.file_bucket.bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.file_uploaded_topic.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.file_processing_queue.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.file_metadata_table.name
}
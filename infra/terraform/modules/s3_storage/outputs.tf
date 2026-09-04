output "bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "The name/ID of the provisioned S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "The Amazon Resource Name (ARN) of the bucket."
}

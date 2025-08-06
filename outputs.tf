output "frontend_bucket_url" {
  description = "URL for the frontend S3 website"
  value       = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
}

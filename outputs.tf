output "frontend_bucket_url" {
  description = "URL for the frontend S3 website"
  value       = aws_s3_bucket_website_configuration.frontend_bucket.website_endpoint
}

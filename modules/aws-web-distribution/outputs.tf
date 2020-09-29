output "cdn_url" {
  description = "URL for the CDN distribution"
  value       = aws_cloudfront_distribution.web_distribution.domain_name
}

output "static_bucket_id" {
  description = "Id of the bucket that holds static files"
  value       = aws_s3_bucket.static_bucket.id

}

output "spa_bucket_id" {
  description = "Id of the bucket that holds SPA web app files"
  value       = aws_s3_bucket.spa_bucket.id
}
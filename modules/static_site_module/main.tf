#Create a CloudFront distribution for hosting static files
resource "aws_cloudfront_distribution" "static_site" {
  enabled = true
  # Add your S3 bucket as the origin here (where your static files live)
  origin {
    domain_name = "your-s3-bucket.s3.amazonaws.com"
    origin_id   = "s3-origin"
  }
  # Other settings (SSL, caching, etc.)
  tags = {
    Environment = "dev"
    Component   = "qpc_static_site"
  }
}

# Output the CloudFront domain name (needed for DNS)
output "cloudfront_domain" {
  value = aws_cloudfront_distribution.static_site.domain_name
}
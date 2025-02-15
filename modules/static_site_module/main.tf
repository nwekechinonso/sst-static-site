# S3 Bucket (Origin for CloudFront)
resource "aws_s3_bucket" "static_site" {
  bucket = "${var.app_name}-static-site-${var.resource_suffix}"
  tags   = var.default_tags

  # Block public access and disable versioning
  versioning {
    enabled = false
  }
  lifecycle {
    prevent_destroy = false
  }
}

# ACM Certificate (MUST be in us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cloudfront_cert" {
  provider          = aws.us_east_1
  domain_name       = var.cloudfront_dns_name
  validation_method = "DNS"
  tags              = var.default_tags
}

# CloudFront Distribution (Replicate SST StaticSite config)
resource "aws_cloudfront_distribution" "static_site" {
  enabled     = true
  description = "${var.app_name} StaticSite ${var.resource_suffix}"
  web_acl_id  = var.waf_arn

  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = "s3-origin"
  }

  # Add other settings (SSL, caching, etc.) to match the SST/CDK setup
  default_cache_behavior {
    target_origin_id = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = var.default_tags
}

# Outputs
output "bucket_name" {
  value = aws_s3_bucket.static_site.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.static_site.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = "Z2FDTNDATAQYW2" # Fixed CloudFront hosted zone ID
}
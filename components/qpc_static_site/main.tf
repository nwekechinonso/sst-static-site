module "static_site" {
  source             = "../../modules/static_site"
  app_name           = "OPC"
  resource_suffix    = "${var.environment}-sst-3"
  cloudfront_dns_name = "qpc-static.${var.environment}-sst-3.qc.eprintor1.fgm.com"
  default_tags       = var.default_tags
}

# DNS Alias Record (Route 53)
data "aws_route53_zone" "operator_portal" {
  name = "operator-portal-zone" # Replace with actual zone name
}

resource "aws_route53_record" "static_site_alias" {
  zone_id = data.aws_route53_zone.operator_portal.zone_id
  name    = "qpc-static.${var.environment}-sst-3.qc.eprintor1.fgm.com"
  type    = "A"
  alias {
    name                   = module.static_site.cloudfront_domain_name
    zone_id                = module.static_site.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# Delegation for dev-sist-2 and ga-sist-3 subdomains (Ask Guy for existing zones)
resource "aws_route53_zone" "environment_zone" {
  name = "${var.environment}-sst-3.qc.eprintor1.fgm.com"
  tags = var.default_tags
}
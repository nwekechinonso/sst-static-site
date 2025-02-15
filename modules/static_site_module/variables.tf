variable "app_name" {
  type    = string
  default = "OPC"
}

variable "resource_suffix" {
  type = string
}

variable "waf_arn" {
  type    = string
  default = ""
}

variable "cloudfront_dns_name" {
  type = string
}

variable "default_tags" {
  type    = map(string)
  default = {}
}
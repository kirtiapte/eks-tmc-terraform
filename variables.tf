variable "tmc_host" {
  type        = string
  description = "TMC Host"
}

variable "vmw_api_token" {
  type        = string
  sensitive   = true
  description = "TMC API Token"
}

variable "account_id" {
  type        = string
  description = "Account ID for AWS"
}

variable "arn" {
  type        = string
  description = "IAM role ARN for AWS"
}

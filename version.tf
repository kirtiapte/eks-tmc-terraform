terraform {
  required_providers {
    tanzu-mission-control = {
      source  = "vmware/tanzu-mission-control"
      version = "1.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.23.0"
    }
  }
}


# Configure the AWS EKS Provider
provider "AWS_EKS" {
  features {}
  account_id = var.subscription_id
  arn       = var.arn
  ext_id   = var.ext_id
}

provider "tanzu-mission-control" {
  endpoint            = var.vmw_host      # optionally use TMC_ENDPOINT env var
  vmw_cloud_api_token = var.vmw_api_token # optionally use VMW_CLOUD_API_TOKEN env var

  # if you are using dev or different csp endpoint, change the default value below
  # for production environments the csp_endpoint is console.cloud.vmware.com
  # vmw_cloud_api_endpoint = "console.cloud.vmware.com" or optionally use VMW_CLOUD_ENDPOINT env var
}

terraform {
  required_providers {
    tanzu-mission-control = {
      source  = "vmware/tanzu-mission-control"
      version = "1.1.5"
    }
}

provider "tanzu-mission-control" {
  endpoint            = var.tmc_host      # optionally use TMC_ENDPOINT env var
  vmw_cloud_api_token = var.vmw_api_token # optionally use VMW_CLOUD_API_TOKEN env var

  # if you are using dev or different csp endpoint, change the default value below
  # for production environments the csp_endpoint is console.cloud.vmware.com
  # vmw_cloud_api_endpoint = "console.cloud.vmware.com" or optionally use VMW_CLOUD_ENDPOINT env var
}

resource "tanzu-mission-control_credential" "aws_eks_cred" {
  name = "eks-cred-kirti"

  meta {
    description = "credential"
    labels = {
      "key1" : "value1",
    }
  }

  spec {
    capability = "MANAGED_K8S_PROVIDER"
    provider = "AWS_EKS"
    data {
      aws_credential {
        account_id = var.account_id
        iam_role{
          arn = var.arn
          ext_id =""
        }
      }
    }
  }
}

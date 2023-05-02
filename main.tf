terraform {
  required_providers {
    tanzu-mission-control = {
      source = "vmware/tanzu-mission-control"
      version = "1.1.5"    # it's the provider version and you can change it as version changes
    }
  }
}
provider "tanzu-mission-control" {
  endpoint            = var.vmw_host            # optionally use TMC_ENDPOINT env var
  vmw_cloud_api_token = var.vmw_api_token # optionally use VMW_CLOUD_API_TOKEN env var
  # if you are using dev or different csp endpoint, change the default value below
  # for production environments the csp_endpoint is console.cloud.vmware.com
  # vmw_cloud_api_endpoint = "console.cloud.vmware.com" or optionally use VMW_CLOUD_ENDPOINT env var
}

# Create a Tanzu Mission Control AWS EKS cluster entry
resource "tanzu-mission-control_ekscluster" "tf_eks_cluster" {
  credential_name = "tf-eks"          // Required
  region          = "us-west-2"         // Required
  name            = "tf2-eks-cluster-2" // Required

  ready_wait_timeout = "30m" // Wait time for cluster operations to finish (default: 30m).

  meta {
    description = "eks test cluster"
    labels      = { "key1" : "value1" }
  }

  spec {
    cluster_group = "kirti-demo" // Default: default
    #proxy		  = "<proxy>"              // Proxy if used

    config {
      role_arn = "arn:aws:iam::685767138629:role/control-plane.3113216704993936405.eks.tmc.cloud.vmware.com" // Required, forces new

      kubernetes_version = "1.24" // Required
      tags               = { "tagkey" : "tagvalue" }

      kubernetes_network_config {
        service_cidr = "10.100.0.0/16" // Forces new
      }

      logging {
        api_server         = false
        audit              = true
        authenticator      = true
        controller_manager = false
        scheduler          = true
      }

      vpc { // Required
        enable_private_access = true
        enable_public_access  = true
        public_access_cidrs = [
          "0.0.0.0/0",
        ]
        security_groups = [ // Forces new
          "sg-071fcc3347e380890",
        ]
        subnet_ids = [ // Forces new
          "subnet-0f73351d50b9af409",
          "subnet-0501a09b610a6dbac",
          "subnet-0dc6346960290d444",
          "subnet-0ea22442dab17760e"
        ]
      }
    }

    nodepool {
      info {
        name        = "fist-np"
        description = "tf nodepool description"
      }

      spec {
        role_arn       = "arn:aws:iam::685767138629:role/worker.18115418072985548507.eks.tmc.cloud.vmware.com"
        ami_type       = "AL2_x86_64"
        capacity_type  = "ON_DEMAND"
        root_disk_size = 40 // Default: 20GiB
        tags           = { "nptag" : "nptagvalue9" }
        node_labels    = { "nplabelkey" : "nplabelvalue" }

        subnet_ids = [ // Required
          "subnet-0f73351d50b9af409",
          "subnet-0501a09b610a6dbac",
          "subnet-0dc6346960290d444",
          "subnet-0ea22442dab17760e"
        ]
       remote_access {
          ssh_key = "sp-tf-auto-key" // Required (if remote access is specified)

          security_groups = [
            "sg-071fcc3347e380890",
          ]
        }

        scaling_config {
          desired_size = 3
          max_size     = 5
          min_size     = 1
        }

        update_config {
          max_unavailable_nodes = "10"
        }

        instance_types = [
          "t3.medium",
          "m3.large"
        ]

      }
    }
  }
}

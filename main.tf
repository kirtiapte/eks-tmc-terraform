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

// Tanzu Mission Control EKS Cluster Type: AWS EKS clusters.
// Operations supported : Read, Create, Update & Delete

// Read Tanzu Mission Control AWS EKS cluster : fetch cluster details
data "tanzu-mission-control_ekscluster" "tf_eks_cluster" {
  credential_name = "sp-eks-tf-cred" // Required
  region          = "us-east-1"          // Required
  name            = "sp-tf-auto"        // Required
}

// Create Tanzu Mission Control AWS EKS cluster entry
resource "tanzu-mission-control_ekscluster" "tf_eks_cluster" {
  credential_name = "sp-eks-tf-cred" // Required
  region          = "us-east-1"          // Required
  name            = "sp-tf-auto"        // Required

  ready_wait_timeout = "30m" // Wait time for cluster operations to finish (default: 30m).

  meta {
    description = "description of the cluster"
    labels      = { "mode" : "automation", "username" : "sp" }
  }

  spec {
    cluster_group = "sp-cluster-grp" // Default: default
    #proxy         = "" //if used 

    config {
      role_arn           = "arn:aws:iam::687456942232:role/control-plane.11197733977849512268.eks.tmc.cloud.vmware.com" // Required, forces new
      kubernetes_version = "1.24"                // Required
      tags               = { "mode" : "terraform" }

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
          "sg-0395139026e380a43",
        ]
        subnet_ids = [ // Forces new
          "subnet-0071b3b1ec3233eee",
          "subnet-04c5221ee2db53796",
          "subnet-0ecfbfb553eef704a",
          "subnet-09c63bb69bf76578e"
        ]
      }
    }

    nodepool {
      info {
        name        = "small-pool" // Required
        description = "nodepool for eks cluster"
      }

      spec {
        // Refer to nodepool's schema
        role_arn       = "arn:aws:iam::687456942232:role/worker.11197733977849512268.eks.tmc.cloud.vmware.com" // Required
        ami_type       = "AL2_x86_64"
        capacity_type  = "ON_DEMAND"
        root_disk_size = 40 // In GiB, default: 20GiB
        tags           = { "mode" : "automation" }
        node_labels    = { "tool" : "tf" }

        subnet_ids = [ // Required
          "subnet-0071b3b1ec3233eee",
          "subnet-04c5221ee2db53796",
          "subnet-0ecfbfb553eef704a",
          "subnet-09c63bb69bf76578e"
        ]

        remote_access {
          ssh_key = "sp-tf-auto-key" // Required (if remote access is specified)

          security_groups = [
            "sg-0395139026e380a43",
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

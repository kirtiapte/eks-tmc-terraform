# TMC Terraform for EKS

- Create EKS credentials through Tanzu Mission Control UI
- Create VPCs and subnets following this document
https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html
- Use the credentials to create and manage EKS cluster.  Update variables.tf with your TMC host and token.
<pre>
terraform init
terraform apply
</pre>

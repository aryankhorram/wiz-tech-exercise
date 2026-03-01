module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "wiz-eks"
  cluster_version = "1.29"

  vpc_id = aws_vpc.wiz_vpc.id

  # EKS can see both subnets; nodes will be private only
  subnet_ids = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_az2.id,
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet_az2.id
  ]
  #public endpoint so my workstation can use kubectl
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # one node in the private subnet
  eks_managed_node_groups = {
    private_nodes = {
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      subnet_ids = [
        aws_subnet.private_subnet.id,
        aws_subnet.private_subnet_az2.id
      ]
    }
  }
}
data "aws_eks_cluster" "mycluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "mycluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.mycluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.mycluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.mycluster.token
}
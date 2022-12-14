module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.12.2"

  cluster_name       = local.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  cluster_version    = local.cluster_version

  self_managed_node_groups = {
    self_m5 = {
      node_group_name        = local.worker_node_group_name
      create_launch_template = true
      launch_template_os     = "bottlerocket"
      instance_types         = "m5.large"
      min_size               = 2
      desired_size           = 2
      max_size               = 2
      subnet_ids             = module.vpc.private_subnets

      k8s_labels = {
        WorkerType = "microservice"
      }
    }
  }
  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source                   = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.12.2/modules/kubernetes-addons"
  eks_cluster_id           = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint     = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider        = module.eks_blueprints.oidc_provider
  eks_cluster_version      = module.eks_blueprints.eks_cluster_version
  auto_scaling_group_names = module.eks_blueprints.self_managed_node_group_autoscaling_groups

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni            = false
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = false
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Add-ons
  enable_cilium           = true
  cilium_helm_config = {
    name       = "cilium"
    repository = "https://helm.cilium.io/"
    chart      = "cilium"
    version    = "1.12.1"
    values = [templatefile("cilium/values.yaml", {})]
  }

  cilium_enable_wireguard = true

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway     = true
  create_igw             = true
  enable_dns_hostnames   = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_name      = "${local.name}-default"
  manage_default_security_group = true
  default_security_group_name   = "${local.name}-default"

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = local.tags
}

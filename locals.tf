locals {
  name = basename(path.cwd)
  region = "ap-southeast-1"
  cluster_version = "1.23"

  vpc_cidr = "10.0.0.0/16"
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  controller_node_group_name = "self-managed-controller"
  worker_node_group_name = "self-managed-worker-1"

  cilium_charts_url = "https://helm.cilium.io/"

  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"
  istio_namespace = "istio-system"

  tags = {
    Environment = "dev"
    Terraform = "true"
  }
}

server_type_master = "g6-standard-1"
cluster_name = "example-cluster-2"
ssh = [ "SSH_SED" ]
token = "TOKEN_SED"


label = "terraformKubernetesWorker"
k8s_version = "1.24"
region = "us-east"
pools = [
  {
    type : "g6-standard-1"
    count : 3
  }
]

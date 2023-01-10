#Rename to terraform.auto.tfvars when obtained token + ssh is added to an account token is obtained from.

label = "terraformKubernetesWorker"
k8s_version = "1.24"
region = "us-east"
pools = [
  {
    type : "g6-standard-1"
    count : 3
  }
]
token = "TOKEN_SED"
ssh = [ "SSH_SED" ]
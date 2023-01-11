terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.27.1"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

resource "linode_instance" "kubeHost" {
        image = "linode/ubuntu18.04"
        label = "terraformHost"
        group = "Terraform"
        region = "us-east"
        type = "g6-nanode-1"
        authorized_keys = var.ssh
        root_pass = "aUIdnkA87cAHJK21"
}

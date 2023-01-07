terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.27.1"
    }
  }
}

provider "linode" {
  token = "949505f61e40135f06bf04fe99c699d15b008f8ca2a6e430d437fd3b752735ab"
}

resource "linode_instance" "kubeHost" {
        image = "linode/ubuntu18.04"
        label = "terraformHost"
        group = "Terraform"
        region = "us-east"
        type = "g6-nanode-1"
        authorized_keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOofLe0fwWFhBU+ufJjLkUFgByHx0dSSWqKz+ilTI0HO michalcop@bntech.dev" ]
        root_pass = "aUIdnkA87cAHJK21"
}

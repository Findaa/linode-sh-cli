#!/bin/bash

. ./deploy_lib/DatabaseManager.sh

#If used with 1 arg will open ssh, with 2 args will execute ssh param.
#arg1 <- label of node | arg2 <- potential sh command/script
sshConnector() {
  hostIp=$(getNodeIpByName $1)
  inf "connector\t" "Performing ssh connection to $hostIp with command $2"
  sshCommand="ssh root@$hostIp '$2'"
  eval $sshCommand

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "connector\t" "Error connecting with ssh"
  fi
}

kubeClusterDeploy() {
  inf "cloud\t\t" "Starting to deploy kube workers"
  cd tf/cluster
  terraform init
  inf "cloud\t\t" "Terraform initialized. Planning..."
  terraform plan -var-file="../terraform.auto.tfvars" 2>1 1>/dev/null
  inf "cloud\t\t" "Terraform planned. Deploying..."
  terraform apply -var-file="../terraform.auto.tfvars" -auto-approve 2>1 1>/dev/null
  cd ../..
}

#todo: Add validation if cluster exists
kubeClusterDestroy() {
  inf "cloud\t\t" "Removing kube cluster"

  cd tf/cluster
  terraform destroy -var-file="../terraform.auto.tfvars" -auto-approve 2>1 1>/dev/null

  inf "cloud\t\t" "Remote kubernetes cluster removed."

  cd ../..
}

kubeNodesFetchFromCloud() {
  sh deploy_lib/cloud_functions/fetch-nodes.sh
}

kubeClusterDeployFromCloud() {
  sshConnector 'terraformHost' 'cd ../tmp/work && sh deploy_lib/cloud_functions/deploy-cluster.sh'
}

kubeClusterDestroyFromCloud() {
  sshConnector 'terraformHost' 'cd ../tmp/work && sh deploy_lib/cloud_functions/destroy-cluster.sh'
  sh deploy_lib/cloud_functions/destroy-cluster.sh
}

sshConnectionEnd() {
  exit
}

getNodeIpByName() {
  python3 ./deploy_lib/py_lib/fetchKubeNodes
}

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
  else
    inf "connector\t" "Connection tried with ssh"
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
  databaseUpdate
}

kubeClusterDestroy() {
  cd tf/cluster
  terraform destroy -var-file="../terraform.auto.tfvars" -auto-approve 2>1 1>/dev/null

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "cloud\t\t" "Linode cluster could not be deleted. Probably doesn't exist or the work folder was deleted manually. Remove cloud host from linode UI or with cli"
  else
    inf "cloud\t\t" "Remote kubernetes cluster removed."
  fi

  cd ../..
  databaseUpdate
}

getNodeIpByName() {
  python3 ./deploy_lib/py_lib/fetchKubeNodes
}

fetchNodesCloud() {
  python3 ./deploy_lib/py_lib/fetchKubeNodes.py
}

kubeNodesFetchFromCloud() {
  sh deploy_lib/cloud_functions/fetch-nodes.sh
}

kubeClusterDeployFromCloud() {
  sh deploy_lib/cloud_functions/deploy-cluster.sh
}

kubeClusterDestroyFromCloud() {
  sh deploy_lib/cloud_functions/destroy-cluster.sh
}

sshConnectionEnd() {
  exit
}

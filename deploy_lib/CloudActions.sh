#!/bin/bash

. ./deploy_lib/DatabaseManager.sh

#If used with 1 arg will open ssh, with 2 args will execute ssh param.
#arg1 <- label of node | arg2 <- potential sh command/script
sshConnector() {
  hostIp=$(getNodeIpByName $1)
  inf "connector" "Performing ssh connection to $hostIp with command $2"
  sshCommand="ssh root@$hostIp '$2'"
  eval $sshCommand

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "connector" "Error connecting with ssh"
  else
    inf "connector" "Success connecting with ssh"
  fi
}

uploadWorkFiles() {
  hostIp=$(getNodeIpByName 'terraformHost')
  scpAddress="root@$hostIp:/tmp"
  sshCommand="ssh -o 'StrictHostKeyChecking accept-new' root@$hostIp 'ls'"
  find . -name ".DS_Store" -delete

  inf "local-cloud config" "Adding $hostIp to the list of known hosts. This may take a moment as connection needs to be confirmed first."
  eval $sshCommand

  inf "cloud" "Performing upload to $scpAddress"
  scp -r tf/terraform.auto.tfvars $scpAddress
  scp -r deploy_lib $scpAddress
  scp -r tf/cluster $scpAddress
  scp -r worker.sh $scpAddress
  scp -r bin $scpAddress

  #todo: if err
  inf "cloud" "All files uploaded"
}

installTerraformRemoteHost() {
  inf "cloud" "Installing terraform for kube host"
  sshConnector 'terraformHost' 'cd ../tmp/bin && mv terraform /usr/local/bin/ && terraform -v'
}

kubeClusterDeploy() {
  inf "cloud" "Starting to deploy kube workers"
  cd tf/cluster
  terraform init
  inf "cloud" "Terraform initialized. Planning..."
  terraform plan -var-file="../terraform.auto.tfvars" 2>1 1>/dev/null
  inf "cloud" "Terraform planned. Deploying..."
  terraform apply -var-file="../terraform.auto.tfvars" -auto-approve 2>1 1>/dev/null
  cd ../..
}

kubeClusterDestroy() {
  cd tf/cluster
  terraform destroy -var-file="../terraform.auto.tfvars" -auto-approve 2>1 1>/dev/null

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "cloud" "Linode cluster could not be deleted. Probably doesn't exist or the work folder was deleted manually. Remove cloud host from linode UI or with cli"
  else
    inf "cloud" "Remote kubernetes host removed."
  fi

  cd ../..
}

sshConnectionEnd() {
  exit
}
